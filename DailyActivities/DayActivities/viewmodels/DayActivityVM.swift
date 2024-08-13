//
//  TodayActivityVM.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation
import Combine
import Collections

protocol DayActivityVMDelegate: AnyObject {
    func showTypeManager()
    func showHistory()
}
final class DayActivityVM: ObservableObject {
    @Published private(set) var activities = [Activity]()
    @Published private(set) var activeTypes: OrderedSet<ActivityType> = []
    
    private(set) var typeSet: OrderedSet<ActivityType> = []
    @Published private(set) var chartData = [ActivityChartModel]()
    
    private var updateLastActivityChartDataTimer: Timer?
    private let delegate: DayActivityVMDelegate
    
    private var conflictActivitiesID: Set<Activity.ID> = .init()
    
    @Published private(set) var activitiesToReconfigure = Set<Activity.ID>()
    let privateQueue: DispatchQueue
    
    private let chartDataService: ChartDataService
    private let activityRepository: ActivityReadableRepository & ActivityWritableRepository
    private let typeRepository: ActivityTypeReadableRepository
    private var cancellables = Set<AnyCancellable>()
    private let conflictActivitiesMutex = NSLock()
    private let timerMutex = NSRecursiveLock()
    let date: Date

    init(activityRepository: ActivityReadableRepository & ActivityWritableRepository, typeRepository: ActivityTypeReadableRepository, delegate: DayActivityVMDelegate, date: Date) {
        self.date = date
        self.delegate = delegate
        self.activityRepository = activityRepository
        self.typeRepository = typeRepository
        self.chartDataService = ChartDataServiceIml(typeRepository: typeRepository)
        self .privateQueue = DispatchQueue(label: "DayAcitvityVM\(date.formatted())Queue", target: .global(qos: .userInteractive))
        typeSet = .init(typeRepository.types)
        activeTypes = .init(typeRepository.types.filter { $0.isActive })
        typeRepository.typesPublisher
            .receive(on: DispatchQueue.global())
            .sink { [weak self] newTypes in
                guard let self else { return }
                typeSet = .init(newTypes)
                activeTypes = .init(newTypes.filter { $0.isActive })
                let activities = activities
                updateChartData(activities)
            }
            .store(in: &cancellables)
        
        activityRepository.activityDidChangedPublisher
            .receive(on: privateQueue)
            .sink { [weak self] _ in
                guard let self else { return }
                var newActivities = activityRepository.fetchActivities(for: date)
//                guard newActivities != activities else { return }
                newActivities.sort(by: { $0.startDateTime < $1.startDateTime })
                var newConflicts = Set<Activity.ID>()
//                var conflictActivityDictionary: [Activity.ID: Set<Activity.ID>] = [:]
                newConflicts = Set(getOverlappingActivitiesSet(activities: newActivities).map { $0.id })
                self.activities = newActivities
                conflictActivitiesMutex.withLock {
                    let oldConflicts = self.conflictActivitiesID
                    self.conflictActivitiesID = newConflicts
                    self.activitiesToReconfigure = newConflicts.union(oldConflicts)
                }
                updateChartData(activities)
                updateTimer()
            }
            .store(in: &cancellables)
    }
    
    // MARK: Intents
    func addActivity(description: String, typeID: String) {
        if let index = activities.firstIndex(where: { $0.finishDateTime == nil }) {
            activitiesToReconfigure = [activities[index].id]
        }
        
        var activity = Activity(description: description, typeID: typeID, startDateTime: activities.last?.finishDateTime ?? date, finishDateTime: activities.last?.finishDateTime ?? date)
        if date.isSameDay(with: Date()) {
            activity.startDateTime = .now
            activity.finishDateTime = nil
        }
        
        Task { [activity] in
            do {
                try await activityRepository.addActivity(activity)
            } catch {
                print("failed to add activity: \(error.localizedDescription)")
            }
        }
    }
    
    func updateActivity(_ activityToUpdate: Activity, with data: Activity.Data) async {
        guard let index = activities.firstIndex(where: {$0.id == activityToUpdate.id}) else { return }
        guard data.startDateTime <= data.finishDateTime ?? data.startDateTime
                && data.startDateTime.isSameDay(with: data.finishDateTime ?? data.startDateTime)
                && !data.description.isEmpty else { return }
        activities[index].update(from: data)
        do {
            print("try to update activity")
            try await activityRepository.updateActivity(activities[index])
        } catch {
            print("failed to save activity: \(error.localizedDescription)")
        }
        activitiesToReconfigure = [activityToUpdate.id]
    }
    
    func isConflictActivity(with id: Activity.ID) -> Bool {
        conflictActivitiesMutex.withLock {
            conflictActivitiesID.contains(id)
        }
    }
    
    func deleteActivity(_ activityToDelete: Activity) async {
        guard let index = activities.firstIndex(where: {$0.id == activityToDelete.id}) else { return }
        do {
            try await activityRepository.deleteActivity(activityToDelete)
            
        } catch {
            print("failed delete activity: \(error.localizedDescription)")
        }
        conflictActivitiesID.remove(activityToDelete.id)
        activities.remove(at: index)
//
//        updateChartData(activities)
//        updateTimer()
        
    }
    
    func getOverlappingActivitiesSet(activities: [Activity]) -> Set<Activity> {
        var overlappingActivities: Set<Activity> = []

        let sortedActivities = activities.sorted { $0.startDateTime < $1.startDateTime }

        for currentIndex in 0..<sortedActivities.count {
            let currentActivity = sortedActivities[currentIndex]
            let currentEnd = currentActivity.finishDateTime ?? Date.distantFuture

            for nextIndex in currentIndex + 1..<sortedActivities.count {
                let nextActivity = sortedActivities[nextIndex]

                if nextActivity.startDateTime >= currentEnd {
                    break
                }

                let nextEnd = nextActivity.finishDateTime ?? Date.distantFuture
                if currentActivity.startDateTime < nextEnd {
                    overlappingActivities.insert(currentActivity)
                    overlappingActivities.insert(nextActivity)
                }
            }
        }

        return overlappingActivities
    }

    
    private func updateChartData(_ activities: [Activity]) {
        var currentConflicts = Set<Activity.ID>()
        conflictActivitiesMutex.withLock {
            currentConflicts = conflictActivitiesID
        }

        let activitiesWithoutConflict = activities.filter { !currentConflicts.contains($0.id) }
        let newChartData = chartDataService.chartData(for: activitiesWithoutConflict)
        
        self.chartData = newChartData
    }
    
    private func updateTimer() {
        timerMutex.withLock {
            updateLastActivityChartDataTimer?.invalidate()
            if let activity = activities.first(where: {$0.finishDateTime == nil}) {
                updateLastActivityChartDataTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
                    self?.updateChartData([activity])
                })
            } else {
                updateLastActivityChartDataTimer?.invalidate()
            }
        }
    }
    
    func showTypeManager() {
        delegate.showTypeManager()
    }
    
    func showHistory() {
        delegate.showHistory()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        print("\(self) deinited")
    }
    
}

//
//  TodayActivityVM.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation
import Combine
import Collections

protocol TodayActivityVMDelegate: AnyObject {
    func showTypeManager()
    func showHistory()
}

final class TodayActivityVM: ObservableObject {
    @Published private(set) var activities = [Activity]()
    @Published private(set) var activeTypes: OrderedSet<ActivityType> = []
    private(set) var typeSet: OrderedSet<ActivityType> = []
    @Published private(set) var chartData = [ActivityChartModel]()
    private var updateLastActivityChartDataTimer: Timer?
    private let delegate: TodayActivityVMDelegate
    private(set) var conflictActivityDictionary: [Activity.ID: Set<Activity.ID>] = [:]
    @Published private(set) var activitiesToReconfigure = Set<Activity.ID>()
    private let chartDataService: ChartDataService
    private let activityRepository: ActivityReadableRepository & ActivityWritableRepository
    private let typeRepository: ActivityTypeReadableRepository
    private var cancellables = Set<AnyCancellable>()
    private let mutex = NSLock()

    init(activityRepository: ActivityReadableRepository & ActivityWritableRepository, typeRepository: ActivityTypeReadableRepository, delegate: TodayActivityVMDelegate) {
        self.delegate = delegate
        self.activityRepository = activityRepository
        self.typeRepository = typeRepository
        self.chartDataService = ChartDataServiceIml(typeRepository: typeRepository)
        activities = activityRepository.fetchActivities(for: .now)
        typeSet = .init(typeRepository.types)
        activeTypes = .init(typeRepository.types.filter { $0.isActive })
        typeRepository.typesPublisher
            .dropFirst()
            .receive(on: DispatchQueue.global())
            .sink { [weak self] newTypes in
                guard let self else { return }
                typeSet = .init(newTypes)
                activeTypes = .init(newTypes.filter { $0.isActive })
                let activities = activities
                updateChartData(activities)
            }
            .store(in: &cancellables)
        
        Task(priority: .high) {
            let activities = activities
            var newActivitiesToReconfigure = Set<Activity.ID>()
            for activity in activities {
                let conflicts = detectActivityTimeConflicts(for: activity)
                newActivitiesToReconfigure = newActivitiesToReconfigure.union(updateConflictDictionary(for: activity, with: conflictActivityDictionary[activity.id, default: conflicts]))
            }
            activitiesToReconfigure = newActivitiesToReconfigure
            updateChartData(activities)
        }
    }
    
    // MARK: Intents
    func addActivity(description: String, typeID: String) {
        if let index = activities.firstIndex(where: { $0.finishDateTime == nil }) {
            activities[index].finishDateTime = .now
            activitiesToReconfigure = [activities[index].id]
//            updateChartData(activities[index])
        }
        let activity = Activity(description: description, typeID: typeID, startDateTime: .now)
        activities.append(activity)
        Task {
            do {
                try await activityRepository.addActivity(activity)
            } catch {
                print("failed to add activity: \(error.localizedDescription)")
            }
        }
        updateChartData(activities)
        updateTimer()
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
        var newActivitiesToReconfigure = Set<Activity.ID>()
        newActivitiesToReconfigure.insert(activityToUpdate.id)
        
        if activityToUpdate.startDateTime != data.startDateTime || activityToUpdate.finishDateTime != data.finishDateTime {
            let detectedConflicts = detectActivityTimeConflicts(for: activities[index])
            newActivitiesToReconfigure = newActivitiesToReconfigure.union(updateConflictDictionary(for: activityToUpdate, with: detectedConflicts))
        }
        activitiesToReconfigure = newActivitiesToReconfigure
//        updateChartData(activities[activityToUpdate])
        updateChartData(activities)
        updateTimer()
    }
    
    func deleteActivity(_ activityToDelete: Activity) async {
        guard let index = activities.firstIndex(where: {$0.id == activityToDelete.id}) else { return }
        do {
            try await activityRepository.deleteActivity(activityToDelete)
            
        } catch {
            print("failed delete activity: \(error.localizedDescription)")
        }
        activities.remove(at: index)
        var newActivitiesToReconfigure = updateConflictDictionary(for: activityToDelete, with: [])
        newActivitiesToReconfigure.remove(activityToDelete.id)
        updateChartData(activities)
        updateTimer()
        activitiesToReconfigure = newActivitiesToReconfigure
        
    }
    
    private func deleteActivityChartData(for activity: Activity) {
        var chartData = chartData
        chartData.removeAll { $0.activityID == activity.id }
        self.chartData = chartData
    }
    
    // MARK: Conflicts
    private func detectActivityTimeConflicts(for activity: Activity) -> Set<Activity.ID> {
        activities.sort { $0.startDateTime < $1.startDateTime }
        guard let activityIndex = activities.index(matching: activity) else { return [] }
        var conflictActivitiesID = Set<Activity.ID>()
        var currentCheckIndex = activityIndex - 1
        while currentCheckIndex >= 0 {
            if activities[currentCheckIndex].finishDateTime ?? .now > activity.startDateTime {
                
                conflictActivitiesID.insert(activities[currentCheckIndex].id)
                currentCheckIndex -= 1
            } else {
                break
            }
        }
        currentCheckIndex = activityIndex + 1
        while currentCheckIndex <= activities.count - 1 {
            if activities[currentCheckIndex].startDateTime < activity.finishDateTime ?? .now {
                conflictActivitiesID.insert(activities[currentCheckIndex].id)
                currentCheckIndex += 1
            } else {
                break
            }
        }
        
        return conflictActivitiesID
    }
    
    private func isActivityConflict(_ lhs: Activity.ID, _ rhs: Activity.ID) -> Bool {
        guard let lhsActivity = activities.first(where: {$0.id == lhs}),
              let rhsActivity = activities.first(where: {$0.id == rhs})
        else { return false }
        
        return lhsActivity.finishDateTime ?? .now > rhsActivity.startDateTime && lhsActivity.startDateTime < rhsActivity.finishDateTime ?? .now
    }
    
    private func updateConflictDictionary(for activity: Activity, with conflictSet: Set<Activity.ID>) -> Set<Activity.ID> {
        let lastConflictActivities = conflictActivityDictionary[activity.id] ?? []
        var activitiesWithoutConflict = lastConflictActivities.subtracting(conflictSet)
        mutex.withLock {
            conflictActivityDictionary.removeValue(forKey: activity.id)
        }
        
        if !conflictSet.isEmpty {
            mutex.withLock {
                conflictActivityDictionary[activity.id] = conflictSet
            }
//            for activityID in conflictSet {
//                if let index = activities.index(matching: activityID) {
//                    updateChartData(activities[index])
//                }
//            }
        }
        
//        for activityID in activitiesWithoutConflict {
//            if let index = activities.index(matching: activityID) {
//                updateChartData(activities[index])
//            }
//        }
        
        for activityID in conflictActivityDictionary.keys {
            if let conflicts = conflictActivityDictionary[activityID], conflicts.contains(activity.id) {
                if !isActivityConflict(activityID, activity.id) {
                    if conflictActivityDictionary[activityID]!.count > 1 {
                        mutex.withLock {
                            conflictActivityDictionary[activityID]?.remove(activity.id)
                        }
                    } else {
                        activitiesWithoutConflict.insert(activityID)
                        mutex.withLock {
                            conflictActivityDictionary.removeValue(forKey: activityID)
                        }
//                        if let index = activities.index(matching: activityID) {
//                            updateChartData(activities[index])
//                        }
                    }
                }
            }
        }
        return activitiesWithoutConflict.union(conflictSet)
        
//            .subtracting([activity.id])
    }
    
    private func updateChartData(_ activities: [Activity]) {
        let activitiesWithoutConflict = activities.filter { activity in conflictActivityDictionary[activity.id] == nil && !conflictActivityDictionary.values.contains(where: { $0.contains(activity.id) }) }
        let newChartData = chartDataService.chartData(for: activitiesWithoutConflict)
        
        self.chartData = newChartData
    }
    
    private func updateTimer() {
        updateLastActivityChartDataTimer?.invalidate()
        if let activity = activities.first(where: {$0.finishDateTime == nil}) {
            updateLastActivityChartDataTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
                self?.updateChartData([activity])
            })
        } else {
            updateLastActivityChartDataTimer?.invalidate()
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

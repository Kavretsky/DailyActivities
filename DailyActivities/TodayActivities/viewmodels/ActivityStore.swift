//
//  ActivityStore.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation
import Combine
import CoreData

protocol ActivityRepository {
    func fetchActivities() async throws -> [Activity]
    func saveActivity(_ activity: Activity) async throws
    func deleteActivity(_ activity: Activity) async throws
}

final class ActivityStore: ObservableObject {
    private(set) var activities = [Activity]()
    @Published private(set) var chartData = [ChartData]()
    private var updateLastActivityChartDataTimer: Timer?
    private(set) var conflictActivityDictionary: [Activity.ID: Set<Activity.ID>] = [:]
    private(set) var activitiesToReconfigure = [Activity.ID]()
    private let context = CoreDataManager.shared.context
    
    var datesInHistory: Set<Date> {
        activities.reduce(into: Set<Date>.init()) { partialResult, activity in
            partialResult.insert(activity.startDateTime)
        }
    }
    
    init() {
        fetchActivities()
    }
    
    // MARK: Intents
    func addActivity(description: String, typeID: String) {
        if let index = activities.firstIndex(where: { $0.finishDateTime == nil }) {
            activities[index].finishDateTime = .now
            updateActivityChartData(activities[index])
        }
        let activity = Activity(description: description, typeID: typeID, startDateTime: .now)
        saveActivity(activity)
        activities.append(activity)
        updateActivityChartData(activity)
        updateTimer()
    }
    
    func activities(for specificDate: Date) -> [Activity] {
        activities.filter { $0.startDateTime.isSameDay(with: specificDate) }
    }
    
    func updateActivity(_ activityToUpdate: Activity, with data: Activity.Data) {
        guard let index = activities.firstIndex(where: {$0.id == activityToUpdate.id}) else { return }
        guard data.startDateTime <= data.finishDateTime ?? data.startDateTime
                && data.startDateTime.isSameDay(with: data.finishDateTime ?? data.startDateTime)
                && !data.description.isEmpty else { return }
        activities[index].update(from: data)

        if activityToUpdate.startDateTime != data.startDateTime || activityToUpdate.finishDateTime != data.finishDateTime {
            let detectedConflicts = detectActivityTimeConflicts(for: activities[index])
            updateConflictDictionary(for: activityToUpdate, with: detectedConflicts)
        }
        updateActivityChartData(activities[activityToUpdate])
        saveActivity(activities[index])
        updateTimer()
    }
    
    func deleteActivity(_ activityToDelete: Activity) {
        guard let index = activities.firstIndex(where: {$0.id == activityToDelete.id}) else { return }
        
        let activityEntity = fetchActivityEntity(by: activityToDelete.id)
        if let activityEntity {
            context.delete(activityEntity)
            CoreDataManager.shared.saveContext()
        }
        
        activities.remove(at: index)
        var chartData = chartData
        chartData.removeAll(where: {$0.activityID == activityToDelete.id})
        DispatchQueue.main.async {
            self.chartData = chartData
        }
        updateConflictDictionary(for: activityToDelete, with: [])
        updateTimer()
    }
    
    private func detectActivityTimeConflicts(for activity: Activity) -> Set<Activity.ID> {
        activities.sort { $0.startDateTime < $1.startDateTime }
        guard let activityIndex = activities.index(matching: activity) else { return [] }
        var conflictActivitiesID = Set<Activity.ID>()
        var currentCheckIndex = activityIndex - 1
        while currentCheckIndex >= 0 {
            if let activityFinishDateTime = activities[currentCheckIndex].finishDateTime, activityFinishDateTime > activity.startDateTime {
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
    
    private func updateConflictDictionary(for activity: Activity, with conflictSet: Set<Activity.ID>) {
        let lastConflictActivities = conflictActivityDictionary[activity.id] ?? []
        var activitiesWithoutConflict = lastConflictActivities.subtracting(conflictSet)
        conflictActivityDictionary.removeValue(forKey: activity.id)
        
        if !conflictSet.isEmpty {
            conflictActivityDictionary[activity.id] = conflictSet
            for activityID in conflictSet {
                if let index = activities.index(matching: activityID) {
                    updateActivityChartData(activities[index])
                }
            }
        }
        
        for activityID in activitiesWithoutConflict {
            if let index = activities.index(matching: activityID) {
                updateActivityChartData(activities[index])
            }
        }
        
        for activityID in conflictActivityDictionary.keys {
            if let conflicts = conflictActivityDictionary[activityID], conflicts.contains(activity.id) {
                if !isActivityConflict(activityID, activity.id) {
                    if conflictActivityDictionary[activityID]!.count > 1 {
                        conflictActivityDictionary[activityID]?.remove(activity.id)
                    } else {
                        activitiesWithoutConflict.insert(activityID)
                        conflictActivityDictionary.removeValue(forKey: activityID)
                        if let index = activities.index(matching: activityID) {
                            updateActivityChartData(activities[index])
                        }
                    }
                }
            }
        }
        activitiesToReconfigure = Array(activitiesWithoutConflict.union(conflictSet))
    }
    
    private func chartDataFromActivity(_ activity: Activity) -> [ChartData] {
        var result = [ChartData]()
        var chartDataStartTime = activity.startDateTime
        var activityStartMinute = Int(activity.startDateTime.formatted(.dateTime.minute()))!
        var activityDuration = DateInterval(start: activity.startDateTime, end: activity.finishDateTime ?? .now.advanced(by: 60)).duration / 60
        
        while activityDuration > 0 {
            let chartDataDuration = min(60 - Double(activityStartMinute), activityDuration)
            let chartData = ChartData(typeID: activity.typeID, startTime: chartDataStartTime, duration: chartDataDuration, activityID: activity.id)
            result.append(chartData)
            activityDuration -= chartDataDuration
            chartDataStartTime = chartDataStartTime.addingTimeInterval(TimeInterval(chartDataDuration * 60))
            activityStartMinute = 0
        }
        
        return result
    }
    
    private func updateActivityChartData(_ activity: Activity) {
        var chartData = chartData
        chartData.removeAll(where: {$0.activityID == activity.id})
        guard !conflictActivityDictionary.contains(where: {
            $0.key == activity.id || $0.value.contains(activity.id)
        }) else {
            self.chartData = chartData
            return
        }
        
        chartDataFromActivity(activity).forEach { element in
            chartData.append(element)
        }
        chartData.sort(by: {$0.startTime < $1.startTime})
        self.chartData = chartData
    }
    
    private func updateTimer() {
        updateLastActivityChartDataTimer?.invalidate()
        if let activity = activities.first(where: {$0.finishDateTime == nil}) {
            updateLastActivityChartDataTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
                self?.updateActivityChartData(activity)
            })
        } else {
            updateLastActivityChartDataTimer?.invalidate()
        }
    }
    
    // MARK: Persistance
    private func fetchActivities() {
        let request: NSFetchRequest<ActivityEntity> = ActivityEntity.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            self.activities = result.map { Activity(from: $0) }
        } catch {
            print("Failed to fetch activities: \(error.localizedDescription)")
        }
    }
    
    private func saveActivity(_ activty: Activity) {
        let activityEntity = fetchActivityEntity(by: activty.id) ?? ActivityEntity(context: context)
        
        activityEntity.id = activty.id
        activityEntity.desc = activty.description
        activityEntity.finishDateTime = activty.finishDateTime
        activityEntity.startDateTime = activty.startDateTime
        activityEntity.typeId = activty.typeID
        
        CoreDataManager.shared.saveContext()
    }
    
    private func fetchActivityEntity(by id: String) -> ActivityEntity? {
        let request = ActivityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            print("\(#function), \(Thread.isMainThread)")
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch activity entity: \(error.localizedDescription)")
            return nil
        }
    }
    
}

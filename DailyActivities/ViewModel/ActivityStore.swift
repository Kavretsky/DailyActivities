//
//  ActivityStore.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation
import Combine


final class ActivityStore: ObservableObject {
    private(set) var activities = [Activity]()
    @Published private(set) var chartData = [ChartData]()
    private var updateLastActivityChartDataTimer: Timer?
    private(set) var conflictActivityDictionary: [Activity.ID: Set<Activity.ID>] = [:]
    private(set) var activitiesToReconfigure = [Activity.ID]()
    
    
    var datesInHistory: Set<Date> {
        activities.reduce(into: Set<Date>.init()) { partialResult, activity in
            partialResult.insert(activity.startDateTime)
        }
    }
    
    init() {
        addActivity(description: "Morning walking with dog", typeID: "4300197B-201F-42CC-AB52-67186E41F668")
        addActivity(description: "Working on new project", typeID: "C286CACB-51A6-4FD8-87E1-6900C8ECC1A9")
    }
    
    //MARK: Intents
    func addActivity(description: String, typeID: String) {
        if let index = activities.firstIndex(where: { $0.finishDateTime == nil }) {
            activities[index].finishDateTime = .now
            updateActivityChartData(activities[index])
        }
        let activity = Activity(description: description, typeID: typeID, startDateTime: .now)
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
        
        updateTimer()
    }
    
    func deleteActivity(_ activityToDelete: Activity) {
        guard let index = activities.firstIndex(where: {$0.id == activityToDelete.id}) else { return }
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
        guard !conflictActivityDictionary.contains(where: {$0.key == activity.id || $0.value.contains(activity.id) }) else {
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
            updateLastActivityChartDataTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] timer in
                self?.updateActivityChartData(activity)
            })
        } else {
            updateLastActivityChartDataTimer?.invalidate()
        }
    }
    
}

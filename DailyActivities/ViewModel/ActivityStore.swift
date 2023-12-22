//
//  ActivityStore.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation
import Combine


final class ActivityStore: ObservableObject {
    @Published private(set) var activities = [Activity]()
    private(set) var activitiesConflict: [String: Bool] = [:]
    @Published private(set) var chartData = [ChartData]()
    private var updateLastActivityChartDataTimer: Timer?
        
    
    
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
        chartDataFromActivity(activity).forEach { element in
            chartData.append(element)
        }
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
        
        updateActivityChartData(activities[index])
        updateTimer()
    }
    
    func deleteActivity(_ activityToDelete: Activity) {
        guard let index = activities.firstIndex(where: {$0.id == activityToDelete.id}) else { return }
        activities.remove(at: index)
        chartData.removeAll(where: {$0.activityID == activityToDelete.id})
        updateTimer()
    }
    
    private func updateActivityConflict(at indexPath: Int) {
        
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
//        var curentChartDataArray = chartData.filter {$0.activityID == activity.id}
//        let newChartDataArray = chartDataFromActivity(activity)
//        let maxIndex = max(curentChartDataArray.count, newChartDataArray.count)
//        for index in 0..<maxIndex {
//            switch (curentChartDataArray[index], newChartDataArray[index]) {
//            case (let curentChartData, let newChartData):
//                curentChartDataArray[index].startTime = newChartData.startTime
//                curentChartDataArray[index].duration = newChartData.duration
//                curentChartDataArray[index].typeID = newChartData.activityID
//            case (nil, let newChartData):
//                curentChartDataArray.append(newChartData)
//            }
//        }
        chartData.removeAll(where: {$0.activityID == activity.id})
        chartDataFromActivity(activity).forEach { element in
            chartData.append(element)
        }
        chartData.sort(by: {$0.startTime < $1.startTime})
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

//
//  ChartDataService.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 04.08.2024.
//

import Foundation

protocol ChartDataService {
    func chartData(for activities: [Activity]) -> [ActivityChartModel]
}

class ChartDataServiceIml: ChartDataService {

    private let typeRepository: ActivityTypeReadableRepository
    
    init(typeRepository: ActivityTypeReadableRepository) {
        self.typeRepository = typeRepository
    }
    
    func chartData(for activities: [Activity]) -> [ActivityChartModel] {
        var result = [ActivityChartModel]()
        for activity in activities {
            let chartData = chartData(from: activity)
            result.append(contentsOf: chartData)
        }
        return result
    }
    
    private func chartData(from activity: Activity) -> [ActivityChartModel] {
        var result = [ActivityChartModel]()
        var chartDataStartTime = activity.startDateTime
        var activityStartMinute = Int(activity.startDateTime.formatted(.dateTime.minute()))!
        var activityDuration = DateInterval(start: activity.startDateTime, end: activity.finishDateTime ?? .now.advanced(by: 60)).duration / 60
        while activityDuration > 0 {
            let chartDataDuration = min(60 - Double(activityStartMinute), activityDuration)
            let type = typeRepository.types.first(where: { $0.id == activity.typeID })
            let chartData = ActivityChartModel(
                typeID: activity.typeID,
                startDateTime: chartDataStartTime,
                duration: chartDataDuration,
                color: type?.backgroundRGBA ?? .init(red: 1, green: 1, blue: 1, alpha: 1),
                typeDescription: type?.description ?? "unknown type",
                activityID: activity.id
            )
            
            result.append(chartData)
            activityDuration -= chartDataDuration
            chartDataStartTime = chartDataStartTime.addingTimeInterval(TimeInterval(chartDataDuration * 60))
            activityStartMinute = 0
        }
        
        return result
    }
    
    deinit {
        print("\(self) deinit")
    }
}

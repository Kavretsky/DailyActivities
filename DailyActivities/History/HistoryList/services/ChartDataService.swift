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

struct ChartDataServiceIml: ChartDataService {

    private let typeRepository: ActivityTypeRepository
    private var types: [ActivityType] = []
    
    init(typeRepository: ActivityTypeRepository) async {
        self.typeRepository = typeRepository
        do {
            types = try await typeRepository.fetchTypes()
        } catch {
            print("failed to load types")
        }
        
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
            let typeIndex = types.firstIndex(where: { $0.id == activity.typeID }) ?? 0
            let chartData = ActivityChartModel(
                typeID: activity.typeID,
                startDateTime: chartDataStartTime,
                duration: chartDataDuration,
                color: types[typeIndex].backgroundRGBA, 
                typeDescription: types[typeIndex].description,
                activityID: activity.id
            )
            
            result.append(chartData)
            activityDuration -= chartDataDuration
            chartDataStartTime = chartDataStartTime.addingTimeInterval(TimeInterval(chartDataDuration * 60))
            activityStartMinute = 0
        }
        
        return result
    }
}

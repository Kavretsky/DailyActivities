//
//  ChartViewModel.swift
//  Day Activities
//
//  Created by Nikolay Kavretsky on 01.08.2023.
//

import Foundation

struct ChartData: Identifiable {
    let id = UUID()
    let typeID: String
    let startTime: Date
    let duration: Double
}

class ChartViewModel {
    private var rawData: [Activity]
    
    private func activityToChartData(_ activity: Activity) -> [ChartData] {
        var result = [ChartData]()
        var chartDataStartTime = activity.startDateTime
        var activityStartMinute = Int(activity.startDateTime.formatted(.dateTime.minute()))!
        var activityDuration = DateInterval(start: activity.startDateTime, end: activity.finishDateTime ?? .now.advanced(by: 60)).duration / 60
        
        repeat {
            let chartDataDuration = min(60 - Double(activityStartMinute), activityDuration)
            let chartData = ChartData(typeID: activity.typeID, startTime: chartDataStartTime, duration: chartDataDuration)
            result.append(chartData)
            activityDuration -= chartDataDuration
            chartDataStartTime = chartDataStartTime.addingTimeInterval(TimeInterval(chartDataDuration * 60))
            activityStartMinute = 0
        } while activityDuration > 0
        
        return result
    }
    
    var usedTypes: [String] {
        print(rawData.map( { $0.typeID}).uniqued())
        return rawData.map( { $0.typeID}).uniqued()
    }
    
    var chartData: [ChartData] {
        rawData.flatMap({activityToChartData($0)})
    }
    
    init(data: [Activity]) {
        self.rawData = data
    }
}

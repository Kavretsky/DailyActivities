//
//  MockChartDataService.swift
//  DailyActivitiesTests
//
//  Created by Nikolay Kavretsky on 01.09.2024.
//

import Foundation
@testable import DailyActivities

struct MockChartDataService: ChartDataService {
    func chartData(for activities: [DailyActivities.Activity]) -> [DailyActivities.ActivityChartModel] {
        activities.map {
            ActivityChartModel(typeID: $0.typeID, startDateTime: $0.startDateTime, duration: $0.duration, color: .randomBackgroundRGBA(), typeDescription: "Mock type", activityID: $0.id)
        }
    }
    
    
}

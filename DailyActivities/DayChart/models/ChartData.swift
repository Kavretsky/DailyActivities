//
//  ChartData.swift
//  DailyActivities
//
//  Created by Anastasia Yunak on 16.12.2023.
//

import Foundation

struct ChartData: Identifiable {
    let id = UUID()
    var typeID: String
    var startTime: Date
    var duration: Double
    let activityID: String
}

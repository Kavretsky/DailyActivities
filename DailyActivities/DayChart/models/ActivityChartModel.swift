//
//  ActivityChartModel.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 04.08.2024.
//

import Foundation

struct ActivityChartModel: Identifiable {
    let id: UUID
    let typeID: String
    let startDateTime: Date
    let duration: Double
    let color: RGBAColor
    let typeDescription: String
    let activityID: String
    
    init(id: UUID = UUID(), typeID: String, startDateTime: Date, duration: Double, color: RGBAColor, typeDescription: String, activityID: String) {
        self.id = id
        self.typeID = typeID
        self.startDateTime = startDateTime
        self.duration = duration
        self.color = color
        self.typeDescription = typeDescription
        self.activityID = activityID
    }
}

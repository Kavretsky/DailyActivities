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
    let finishDateTime: Date
    let color: RGBAColor
    
    init(typeID: String, startDateTime: Date, finishDateTime: Date, color: RGBAColor) {
        self.id = UUID()
        self.typeID = typeID
        self.startDateTime = startDateTime
        self.finishDateTime = finishDateTime
        self.color = color
    }
}

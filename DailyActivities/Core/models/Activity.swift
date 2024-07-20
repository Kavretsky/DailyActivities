//
//  Activity.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation

struct Activity: Identifiable, Hashable, Equatable {
    let id = UUID().uuidString
    var description: String
    var typeID: String
    var startDateTime: Date
    var finishDateTime: Date?
    
    var duration: Double {
        DateInterval(start: startDateTime, end: finishDateTime ?? Date.now).duration
    }
    
    init(description: String, typeID: String, startDateTime: Date, finishDateTime: Date? = nil) {
        self.description = description
        self.typeID = typeID
        self.startDateTime = startDateTime
        self.finishDateTime = finishDateTime
    }
    
    static func ==(lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Activity {
    struct Data {
        var description = ""
        var typeID = UUID().uuidString
        var startDateTime = Date.now
        var finishDateTime: Date? = nil
    }
    
    var data: Data {
        Data(description: description, typeID: typeID, startDateTime: startDateTime, finishDateTime: finishDateTime)
    }
    
    mutating func update(from data: Data) {
        description = data.description
        typeID = data.typeID
        startDateTime = data.startDateTime
        finishDateTime = data.finishDateTime
    }
    
    init(data: Data) {
        description = data.description
        typeID = data.typeID
        startDateTime = data.startDateTime
        finishDateTime = data.finishDateTime
    }
}

//
//  Activity.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation

struct Activity: Identifiable, Hashable {
    let id: String
    var description: String
    var typeID: String
    var startDateTime: Date
    var finishDateTime: Date?
    
    var duration: Double {
        DateInterval(start: startDateTime, end: finishDateTime ?? Date.now).duration
    }
    
    init(id: String = UUID().uuidString, description: String, typeID: String, startDateTime: Date, finishDateTime: Date? = nil) {
        self.id = id
        self.description = description
        self.typeID = typeID
        self.startDateTime = startDateTime
        self.finishDateTime = finishDateTime
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
        id = UUID().uuidString
        description = data.description
        typeID = data.typeID
        startDateTime = data.startDateTime
        finishDateTime = data.finishDateTime
    }
}

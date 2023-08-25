//
//  Activity.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 25.08.2023.
//

import Foundation

struct Activity: Identifiable, Hashable {
    let id: String
    var name: String
    var typeID: String
    var startDateTime: Date
    var finishDateTime: Date?
    
    var duration: Double {
        DateInterval(start: startDateTime, end: finishDateTime ?? Date.now).duration
    }
    
    init(id: String = UUID().uuidString, name: String, typeID: String, startDateTime: Date, finishDateTime: Date? = nil) {
        self.id = id
        self.name = name
        self.typeID = typeID
        self.startDateTime = startDateTime
        self.finishDateTime = finishDateTime
    }
}

extension Activity {
    struct Data {
        var name = ""
        var typeID = UUID().uuidString
        var startDateTime = Date.now
        var finishDateTime: Date? = nil
    }
    
    var data: Data {
        Data(name: name, typeID: typeID, startDateTime: startDateTime, finishDateTime: finishDateTime)
    }
    
    mutating func update(from data: Data) {
        name = data.name
        typeID = data.typeID
        startDateTime = data.startDateTime
        finishDateTime = data.finishDateTime
    }
    
    init(data: Data) {
        id = UUID().uuidString
        name = data.name
        typeID = data.typeID
        startDateTime = data.startDateTime
        finishDateTime = data.finishDateTime
    }
}

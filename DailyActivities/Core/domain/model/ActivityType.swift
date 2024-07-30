//
//  ActivityType.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 15.08.2023.
//

import Foundation

struct ActivityType: Identifiable, Hashable {
    let id: String
    var emoji: String
    var isActive: Bool = true
    var backgroundRGBA: RGBAColor
    var description: String
    
    init(id: String = UUID().uuidString, emoji: String, backgroundRGBA: RGBAColor, description: String) {
        self.id = id
        self.emoji = emoji
        self.backgroundRGBA = backgroundRGBA
        self.description = description
    }
}

extension ActivityType {
    init(from entity: ActivityTypeEntity) {
        self.id = entity.id ?? UUID().uuidString
        self.description = entity.typeDescription ?? ""
        self.emoji = entity.emoji ?? ""
        self.isActive = entity.isActive
        self.backgroundRGBA = entity.color != nil ? RGBAColor(from: entity.color!) : RGBAColor.randomBackgroundRGBA()
    }
}

extension ActivityType {
    struct Data: Hashable {
        var emoji = ""
        var backgroundRGBA = RGBAColor(color: .black)
        var description = ""
    }
    
    var data: Data {
        Data(emoji: emoji, backgroundRGBA: backgroundRGBA, description: description)
    }
    
    mutating func update(from data: Data) {
        emoji = data.emoji
        backgroundRGBA = data.backgroundRGBA
        description = data.description
    }
    
    init(data: Data) {
        emoji = data.emoji
        backgroundRGBA = data.backgroundRGBA
        description = data.description
        id = UUID().uuidString
    }
    
    private static func randomEmoji() -> String {
        let emojiRange = 0x1F600...0x1F64F
        let randomScalar = UnicodeScalar(Int.random(in: emojiRange))!
        return String(randomScalar)
    }
    
    static func sampleData() -> Data {
        Data(emoji: randomEmoji(), backgroundRGBA: RGBAColor.randomBackgroundRGBA(), description: "New type")
    }
}

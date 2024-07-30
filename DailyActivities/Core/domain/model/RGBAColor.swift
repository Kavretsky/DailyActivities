//
//  RGBAColor.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 29.07.2024.
//

import Foundation

struct RGBAColor: Codable, Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(from entity: RGBAColorEntity) {
        red = Double(entity.red)
        green = Double(entity.green)
        blue = Double(entity.blue)
        alpha = Double(entity.alpha)
    }
    
    static func randomBackgroundRGBA() -> RGBAColor {
        return RGBAColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
}

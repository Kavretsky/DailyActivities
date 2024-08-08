//
//  RGBAColor.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 29.07.2024.
//

import Foundation
import Charts

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

extension RGBAColor: Plottable {
    var primitivePlottable: String {
        "\(red) \(green) \(blue) \(alpha)"
    }
    
    init?(primitivePlottable: PrimitivePlottable) {
        let values = primitivePlottable.split(separator: " ").compactMap { Double($0) }
        guard values.count == 4 else { return nil }
        red = values[0]
        green = values[1]
        blue = values[2]
        alpha = values[3]
    }
}

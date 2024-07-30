//
//  RGBAColorEntity+.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 24.07.2024.
//
//

import Foundation
import CoreData

@objc(RGBAColorEntity)
public class RGBAColorEntity: NSManagedObject {}

extension RGBAColorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RGBAColorEntity> {
        return NSFetchRequest<RGBAColorEntity>(entityName: "RGBAColorEntity")
    }

    @NSManaged public var alpha: Double
    @NSManaged public var blue: Double
    @NSManaged public var green: Double
    @NSManaged public var red: Double
    @NSManaged public var type: ActivityTypeEntity?
}

extension RGBAColorEntity: Identifiable {

}

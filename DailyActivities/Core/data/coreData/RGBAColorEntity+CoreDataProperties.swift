//
//  RGBAColorEntity+CoreDataProperties.swift
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

    @NSManaged public var alpha: Int16
    @NSManaged public var blue: Int16
    @NSManaged public var green: Int16
    @NSManaged public var id: String?
    @NSManaged public var red: Int16
    @NSManaged public var type: ActivityTypeEntity?

}

extension RGBAColorEntity: Identifiable {

}

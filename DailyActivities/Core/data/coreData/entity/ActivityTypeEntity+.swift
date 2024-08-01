//
//  ActivityTypeEntity+.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 24.07.2024.
//
//

import Foundation
import CoreData

@objc(ActivityTypeEntity)
public class ActivityTypeEntity: NSManagedObject {}

extension ActivityTypeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityTypeEntity> {
        return NSFetchRequest<ActivityTypeEntity>(entityName: "ActivityTypeEntity")
    }

    @NSManaged public var emoji: String?
    @NSManaged public var id: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var typeDescription: String?
    @NSManaged public var color: RGBAColorEntity?

}

extension ActivityTypeEntity: Identifiable {

}

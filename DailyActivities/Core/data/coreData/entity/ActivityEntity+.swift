//
//  ActivityEntity+.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 23.07.2024.
//
//

import Foundation
import CoreData

@objc(ActivityEntity)
public class ActivityEntity: NSManagedObject {}

extension ActivityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityEntity> {
        return NSFetchRequest<ActivityEntity>(entityName: "ActivityEntity")
    }

    @NSManaged public var finishDateTime: Date?
    @NSManaged public var id: String?
    @NSManaged public var startDateTime: Date?
    @NSManaged public var desc: String?
    @NSManaged public var typeId: String?

}

extension ActivityEntity: Identifiable {}

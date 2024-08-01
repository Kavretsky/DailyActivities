//
//  ActivityRepositoryService.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 30.07.2024.
//

import Foundation
import CoreData

struct ActivityRepositoryService: ActivityRepository {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addActivity(_ activity: Activity) async throws {
        try await context.perform {
            try finishCurrentActivity()
            let entity = ActivityEntity(context: context)
            entity.id = activity.id
            entity.desc = activity.description
            entity.startDateTime = activity.startDateTime
            entity.typeID = activity.typeID
            try context.save()
        }
    }
    
    func fetchActivities(for date: Date) async throws -> [Activity] {
        try await context.perform {
            let request = ActivityEntity.fetchRequest()
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            request.predicate = NSPredicate(format: "startDateTime >= %@ AND startDateTime < %@", startOfDay as NSDate, endOfDay as NSDate)
            
            let result = try context.fetch(request)
            return result.map {Activity(from: $0)}
        }
        
    }
    
    func saveActivity(_ activity: Activity) async throws {
        try await context.perform {
            guard let entity = try getActivityEntity(by: activity.id) else { return }
            entity.desc = activity.description
            entity.finishDateTime = activity.finishDateTime
            entity.startDateTime = activity.startDateTime
            entity.typeID = activity.typeID
            try context.save()
        }
    }
    
    func deleteActivity(_ activity: Activity) async throws {
        try await context.perform {
            guard let entity = try getActivityEntity(by: activity.id) else { return }
            context.delete(entity)
            try context.save()
        }
    }
    
    private func getActivityEntity(by id: String) throws -> ActivityEntity? {
        let request = ActivityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return try context.fetch(request).first
    }
    
    private func finishCurrentActivity() throws {
        try context.performAndWait {
            let request = ActivityEntity.fetchRequest()
            request.predicate = NSPredicate(format: "finishDateTime == nil")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ActivityEntity.startDateTime, ascending: true)]
            guard let currentActivity = try context.fetch(request).first else { return }
            if let startDate = currentActivity.startDateTime {
                currentActivity.finishDateTime = startDate.isSameDay(with: Date()) ? .now : .endOfDay(for: startDate)
            }
        }
    }
}

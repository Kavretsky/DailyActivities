//
//  ActivityTypeRepositoryService.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 29.07.2024.
//

import Foundation
import CoreData

struct ActivityTypeRepositoryService: ActivityTypeRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTypes() async throws -> [ActivityType] {
        try await context.perform {
            let request = ActivityTypeEntity.fetchRequest()
            let types = try context.fetch(request)
            return types.map { ActivityType(from: $0) }
        }
    }
    
    func saveType(_ type: ActivityType) async throws {
        try await context.perform {
            let entity = try getTypeEntity(by: type.id) ?? ActivityTypeEntity(context: context)
            entity.id = type.id
            entity.emoji = type.emoji
            entity.isActive = type.isActive
            entity.typeDescription = type.description
            if entity.color == nil {
                entity.color = RGBAColorEntity(context: context)
            }
            entity.color?.alpha = type.backgroundRGBA.alpha
            entity.color?.red = type.backgroundRGBA.red
            entity.color?.green = type.backgroundRGBA.green
            entity.color?.blue = type.backgroundRGBA.blue
            
            try context.save()
        }
    }
    
    func deleteType(_ type: ActivityType) async throws {
        guard let entity = try getTypeEntity(by: type.id) else { return }
        
        try await context.perform {
            entity.isActive = false
            try context.save()
        }
    }
    
    private func getTypeEntity(by id: String) throws -> ActivityTypeEntity? {
        let request = ActivityTypeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return try context.fetch(request).first
    }
}

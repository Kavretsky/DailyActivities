//
//  ActivityTypeCoreDataRepository.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 29.07.2024.
//

import Foundation
import CoreData

enum ActivityTypeCoreDataRepositoryError: Error {
    case invalidTypeData
    case typeNotFound
    case canNotDeleteLastTwoTypes
}

protocol ActivityTypeReadableRepository {
    var types: [ActivityType] { get }
    var typesPublisher: Published<[ActivityType]>.Publisher { get }
}

protocol ActivityTypeWritableRepository {
    func updateType(_ type: ActivityType, with data: ActivityType.Data) async throws
    func deleteType(_ type: ActivityType) async throws
    func addType(with data: ActivityType.Data) async throws -> ActivityType
}

final class ActivityTypeCoreDataRepository: ObservableObject, ActivityTypeReadableRepository, ActivityTypeWritableRepository {
    @Published private(set) var types: [ActivityType] = []
    var typesPublisher: Published<[ActivityType]>.Publisher { $types }
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        do {
            types = try fetchTypesFromCoreData()
            if types.isEmpty {
                loadDefaultTypes()
            }
        } catch {
            print("failed to fetch types from CoreData: \(error.localizedDescription)")
        }
    }
    
    private func fetchTypesFromCoreData() throws -> [ActivityType] {
        try context.performAndWait {
            let request = ActivityTypeEntity.fetchRequest()
            let types = try context.fetch(request)
            return types.map { ActivityType(from: $0) }
        }
    }
    
    @discardableResult
    func addType(with data: ActivityType.Data) async throws -> ActivityType {
        guard !data.description.isEmpty, !data.emoji.isEmpty else { throw ActivityTypeCoreDataRepositoryError.invalidTypeData }
        let type = ActivityType(data: data)
        try await context.perform { [weak self] in
            guard let self else { return }
            let entity = ActivityTypeEntity(context: context)
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
        types.append(type)
        return type
    }
    
    func updateType(_ type: ActivityType, with data: ActivityType.Data) async throws {
        guard isDataValid(data) else { throw ActivityTypeCoreDataRepositoryError.invalidTypeData }
        guard let index = types.firstIndex(of: type) else { throw ActivityTypeCoreDataRepositoryError.typeNotFound}
        try await context.perform { [weak self] in
            guard let self else { return }
            guard let entity = try getTypeEntity(by: type.id) else { return }
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
            do {
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
        types[index].update(from: data)
    }
    
    func deleteType(_ type: ActivityType) async throws {
        guard types.count > 2 else { throw ActivityTypeCoreDataRepositoryError.canNotDeleteLastTwoTypes }
        guard let entity = try getTypeEntity(by: type.id) else { throw ActivityTypeCoreDataRepositoryError.typeNotFound }
        
        try await context.perform { [weak self] in
            guard let self else { return }
            entity.isActive = false
            try context.save()
        }
        types.remove(type)
    }
    
    private func getTypeEntity(by id: String) throws -> ActivityTypeEntity? {
        let request = ActivityTypeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return try context.fetch(request).first
    }
    
    private func isDataValid(_ data: ActivityType.Data) -> Bool {
        !data.emoji.isEmpty && !data.description.isEmpty
    }
    
    private func loadDefaultTypes() {
        let defaultTypesData = [
            ActivityType.Data(
                emoji: "🏃‍♂️",
                backgroundRGBA: RGBAColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1.0),
                description: "Running"
            ),
            ActivityType.Data(
                emoji: "💼",
                backgroundRGBA: RGBAColor(red: 0.3, green: 0.3, blue: 0.9, alpha: 1.0),
                description: "Work"
            ),
            ActivityType.Data(
                emoji: "☕️",
                backgroundRGBA: RGBAColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0),
                description: "Break"
            ),
            ActivityType.Data(
                emoji: "🧘‍♀️",
                backgroundRGBA: RGBAColor(red: 0.5, green: 0.1, blue: 0.6, alpha: 1.0),
                description: "Yoga"
            ),
            ActivityType.Data(
                emoji: "🎨",
                backgroundRGBA: RGBAColor(red: 0.9, green: 0.6, blue: 0.1, alpha: 1.0),
                description: "Art"
            )
        ]
        
        Task {
            for data in defaultTypesData {
                do {
                    try await addType(with: data)
                } catch {
                    print("failed to save default types: \(error.localizedDescription)")
                }
            }
        }
    }
}

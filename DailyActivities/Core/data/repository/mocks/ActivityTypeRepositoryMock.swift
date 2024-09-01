//
//  ActivityTypeRepositoryMock.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 29.07.2024.
//

import Foundation
import Combine

class ActivityTypeRepositoryMock: ActivityTypeReadableRepository {
    @Published var types: [ActivityType] = mockTypes
    
    var typesPublisher: Published<[ActivityType]>.Publisher { $types }
    init() {
        types = mockTypes
    }
}

extension ActivityTypeRepositoryMock: ActivityTypeWritableRepository {
    func updateType(_ type: ActivityType, with data: ActivityType.Data) async throws {
        if let index = mockTypes.firstIndex(where: { $0.id == type.id }) {
            types[index].update(from: type.data)
        }
    }
    
    func addType(with data: ActivityType.Data) async throws -> ActivityType {
        let newType = ActivityType(data: data)
        types.append(newType)
        return newType
    }
    
    func deleteType(_ type: ActivityType) async throws {
        if let index = mockTypes.firstIndex(where: { $0.id == type.id }) {
            types[index].isActive = false
        }
    }
}

fileprivate let mockTypes: [ActivityType] = [
    ActivityType(
        id: "8A94FA14-5D6D-4A94-9D61-1A8B16C70D48",
        emoji: "🏃‍♂️",
        backgroundRGBA: RGBAColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1.0),
        description: "Running"
    ),
    ActivityType(
        id: "B56A1C12-E1C5-4E1C-9D6A-ABCD78C4F2D3",
        emoji: "💼",
        backgroundRGBA: RGBAColor(red: 0.3, green: 0.3, blue: 0.9, alpha: 1.0),
        description: "Work"
    ),
    ActivityType(
        id: "C6F4B514-1D9F-4B94-9C8F-123F456E7F89",
        emoji: "☕️",
        backgroundRGBA: RGBAColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0),
        description: "Break"
    ),
    ActivityType(
        id: "D7E5C614-8A2F-4E1A-9D4F-678CDEF9ABCD",
        emoji: "🧘‍♀️",
        backgroundRGBA: RGBAColor(red: 0.5, green: 0.1, blue: 0.6, alpha: 1.0),
        description: "Yoga"
    ),
    ActivityType(
        id: "E8F6D714-3B5F-4C1A-9D1E-9ABCFEDCBA98",
        emoji: "🎨",
        backgroundRGBA: RGBAColor(red: 0.9, green: 0.6, blue: 0.1, alpha: 1.0),
        description: "Art"
    )
]

//
//  ActivityRepositoryMock.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 31.07.2024.
//

import Foundation

class ActivityRepositoryMock: ActivityReadableRepository {
    private(set) var mockActivities: [Activity] = [
        Activity(
            description: "Run with dog",
            typeID: "8A94FA14-5D6D-4A94-9D61-1A8B16C70D48",
            startDateTime: Date(timeIntervalSinceNow: -88000),
            finishDateTime: Date(timeIntervalSinceNow: -86400)
        ),
        Activity(
            description: "Morning Run",
            typeID: "8A94FA14-5D6D-4A94-9D61-1A8B16C70D48",
            startDateTime: Date(timeIntervalSinceNow: -3600),
            finishDateTime: Date(timeIntervalSinceNow: -1800)
        ),
        Activity(
            description: "Team Meeting",
            typeID: "B56A1C12-E1C5-4E1C-9D6A-ABCD78C4F2D3",
            startDateTime: Date(timeIntervalSinceNow: -7200),
            finishDateTime: Date(timeIntervalSinceNow: -3600)
        ),
        Activity(
            description: "Coffee Break",
            typeID: "C6F4B514-1D9F-4B94-9C8F-123F456E7F89",
            startDateTime: Date(timeIntervalSinceNow: -9900),
            finishDateTime: Date(timeIntervalSinceNow: -7200)
        ),
        Activity(
            description: "Project Planning",
            typeID: "B56A1C12-E1C5-4E1C-9D6A-ABCD78C4F2D3",
            startDateTime: Date(timeIntervalSinceNow: -14400),
            finishDateTime: Date(timeIntervalSinceNow: -10800)
        ),
        Activity(
            description: "Evening Yoga Session",
            typeID: "D7E5C614-8A2F-4E1A-9D4F-678CDEF9ABCD",
            startDateTime: Date(timeIntervalSinceNow: -1800),
            finishDateTime: nil
        )
    ]
    
    func fetchActivities(for date: Date) -> [Activity] {
        return mockActivities.filter({ $0.startDateTime.isSameDay(with: date)})
    }
    
}

extension ActivityRepositoryMock: ActivityWritableRepository {
    func addActivity(_ activity: Activity) async throws {
        mockActivities.append(activity)
    }
    
    func updateActivity(_ activity: Activity) async throws {
        guard let index = mockActivities.firstIndex(where: { $0.id == activity.id}) else { return }
        mockActivities[index] = activity
    }
    
    func deleteActivity(_ activity: Activity) async throws {
        mockActivities.remove(activity)
    }
}

extension ActivityRepositoryMock: HistoryRepository {
    func fetchHistoryDates() async throws -> [Date] {
        return mockActivities.map { Calendar.current.startOfDay(for: $0.startDateTime )}.uniqued().sorted(by: >)
    }
}

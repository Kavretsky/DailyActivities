//
//  ActivityRepositoryService+HistoryRepository.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 02.08.2024.
//

import Foundation
import Collections

extension ActivityRepositoryService: HistoryRepository {
    
    func fetchHistoryDates() async throws -> [Date] {
        try await context.perform {
            let request = ActivityEntity.fetchRequest()
            request.propertiesToFetch = ["startDateTime"]
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ActivityEntity.startDateTime, ascending: true)]
            request.returnsDistinctResults = true
            
            let result = try context.fetch(request)
            let dates = result.compactMap { $0.startDateTime }
            let uniqueDates = OrderedSet(dates.map { Calendar.current.startOfDay(for: $0) }).elements
            return uniqueDates
        }
    }
}

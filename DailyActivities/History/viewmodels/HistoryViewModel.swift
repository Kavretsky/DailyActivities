//
//  HistoryViewModel.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 01.08.2024.
//

import Foundation

protocol HistoryRepository {
    func fetchActivities(for date: Date) async throws -> [Activity]
    func fetchHistoryDates() async throws -> [Date]
}

final class HistoryViewModel {
    private let historyService: HistoryRepository
    @Published private(set) var dates: [DateComponents: [Date]] = [:]
    private(set) var headers: [DateComponents] = []
    
    init(historyService: HistoryRepository) {
        self.historyService = historyService
        Task {
            let result = try await historyService.fetchHistoryDates()
            dates = Dictionary(grouping: result) { date in
                return Calendar.current.dateComponents([.month, .year], from: date)
            }
            headers = dates.keys.map { $0 }
            
        }
    }
    
    func loadActivities(for date: Date) async -> [Activity] {
        do {
            return try await historyService.fetchActivities(for: date)
        } catch {
            print("failed to load activities for \(date): \(error.localizedDescription)")
        }
        return []
    }
    
    func loadHistoryDates() async -> [Date] {
        do {
            return try await historyService.fetchHistoryDates()
        } catch {
            print("failed to load history dates: \(error.localizedDescription)")
        }
        return []
    }
}

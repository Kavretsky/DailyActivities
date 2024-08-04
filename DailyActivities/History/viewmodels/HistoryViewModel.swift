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

protocol ChartDataService {
    func chartData(for activities: [Activity]) -> [ActivityChartModel]
}

final class HistoryViewModel {
    private let historyService: HistoryRepository
    private let chartDataService: ChartDataService
    @Published private(set) var dates: [DateComponents: [Date]] = [:]
    private(set) var headers: [DateComponents] = []
    private var activityDic: [Date: [Activity]] = [:]
    private(set) var chartDataDic: [Date: [ActivityChartModel]] = [:]
    
    init(historyService: HistoryRepository, chartDataService: ChartDataService) {
        self.chartDataService = chartDataService
        self.historyService = historyService
        Task {
            let result = try await historyService.fetchHistoryDates()
            
            for date in result {
                activityDic[date] = await loadActivities(for: date)
                chartDataDic[date] = chartDataService.chartData(for: activityDic[date] ?? [])
            }
            
            dates = Dictionary(grouping: result) { date in
                return Calendar.current.dateComponents([.year], from: date)
            }
            headers = dates.keys.map { $0 }
        }
    }
    
    private func loadActivities(for date: Date) async -> [Activity] {
        do {
            return try await historyService.fetchActivities(for: date)
        } catch {
            print("failed to load activities for \(date): \(error.localizedDescription)")
        }
        return []
    }
    
    private func loadHistoryDates() async -> [Date] {
        do {
            return try await historyService.fetchHistoryDates()
        } catch {
            print("failed to load history dates: \(error.localizedDescription)")
        }
        return []
    }
}

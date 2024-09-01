//
//  HistoryViewModel.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 01.08.2024.
//

import Foundation
import Collections

protocol HistoryRepository {
    func fetchActivities(for date: Date) async throws -> [Activity]
    func fetchHistoryDates() async throws -> [Date]
}

protocol HistoryViewModelDelegate: AnyObject {
    func openDayActivityVC(for date: Date)
}
@MainActor
final class HistoryViewModel: ObservableObject {
    private let historyService: HistoryRepository
    private let chartDataService: ChartDataService
    @Published private(set) var dates: [DateComponents: [Date]] = [:]
    private(set) var headers: [DateComponents] = []
    private var activityDic: [Date: [Activity]] = [:]
    private(set) var chartDataDic: [Date: [ActivityChartModel]] = [:]
    var delegate: HistoryViewModelDelegate?
    
    init(historyService: HistoryRepository, chartDataService: ChartDataService) {
        self.chartDataService = chartDataService
        self.historyService = historyService
    }
    
    private func loadActivities(for date: Date) async -> [Activity] {
        do {
            return try await historyService.fetchActivities(for: date)
        } catch {
            print("failed to load activities for \(date): \(error.localizedDescription)")
        }
        return []
    }
    
    deinit {
        print("HistoryViewModel deinit")
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) async {
        let key = headers[indexPath.section]
        let daysArray = dates[key, default: []]
        guard daysArray.count > indexPath.row else { return }
        
        delegate?.openDayActivityVC(for: daysArray[indexPath.row])
        
    }
    
    func loadData() async throws {
        
        let result = try await historyService.fetchHistoryDates().filter { !$0.isSameDay(with: .now) }
        
        for date in result {
            activityDic[date] = await loadActivities(for: date)
            chartDataDic[date] = chartDataService.chartData(for: activityDic[date] ?? [])
        }
        let dates = Dictionary(grouping: result) { date in
            return Calendar.current.dateComponents([.year], from: date)
        }
        let headers = dates.keys.map { $0 }
        self.headers = headers
        self.dates = dates
    }
}

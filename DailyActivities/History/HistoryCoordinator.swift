//
//  HistoryCoordinator.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 07.08.2024.
//

import UIKit

final class HistoryCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let activityTypeRepository: ActivityTypeReadableRepository
    private let activityRepository: ActivityReadableRepository & HistoryRepository
    private weak var historyNC: UINavigationController!
    
    init(navigationController: UINavigationController, activityTypeRepository: ActivityTypeReadableRepository, activityRepository: ActivityReadableRepository & HistoryRepository) {
        self.navigationController = navigationController
        self.activityTypeRepository = activityTypeRepository
        self.activityRepository = activityRepository
    }
    
    func start() {
        let chartDataService = ChartDataServiceIml(typeRepository: activityTypeRepository)
        let historyVM = HistoryViewModel(historyService: activityRepository, chartDataService: chartDataService)
        historyVM.delegate = self
        let historyVC = HistoryTableViewController(historyVM: historyVM)
        historyNC = UINavigationController(rootViewController: historyVC)
        historyNC.modalPresentationStyle = .fullScreen
        navigationController.present(historyNC, animated: true)
    }
}

extension HistoryCoordinator: HistoryViewModelDelegate {
    func openDayActivityVC(for date: Date) {
        guard let activityRepository = activityRepository as? ActivityReadableRepository & ActivityWritableRepository,
              let activityTypeRepository = activityTypeRepository as? ActivityTypeReadableRepository & ActivityTypeWritableRepository
        else { return }
        let dayCoordinator = DayActivityCoordinator(navigationController: historyNC, date: date, activityTypeRepository: activityTypeRepository, activityRepository: activityRepository)
        dayCoordinator.start()
    }
}

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
    
    init(navigationController: UINavigationController, activityTypeRepository: ActivityTypeReadableRepository, activityRepository: ActivityReadableRepository & HistoryRepository) {
        self.navigationController = navigationController
        self.activityTypeRepository = activityTypeRepository
        self.activityRepository = activityRepository
    }
    
    func start() {
        let chartDataService = ChartDataServiceIml(typeRepository: activityTypeRepository)
        let historyVM = HistoryViewModel(historyService: activityRepository, chartDataService: chartDataService)
        let historyVC = HistoryTableViewController(historyVM: historyVM)
        let historyNC = UINavigationController(rootViewController: historyVC)
        historyNC.modalPresentationStyle = .fullScreen
        navigationController.present(historyNC, animated: true)
    }
    
}

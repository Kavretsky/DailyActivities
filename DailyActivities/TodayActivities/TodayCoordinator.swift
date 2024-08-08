//
//  TodayCoordinator.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 05.08.2024.
//

import UIKit

final class TodayCoordinator: Coordinator {
    let navigationController: UINavigationController
    let activityTypeRepository: ActivityTypeCoreDataRepository
    let activityRepository: ActivityCoreDataRepository
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        activityRepository = .init(context: CoreDataManager.shared.backgroundContext)
        activityTypeRepository = .init(context: CoreDataManager.shared.backgroundContext)
    }
    
    func start() {
        let todayActivityVM = TodayActivityVM(activityRepository: activityRepository, typeRepository: activityTypeRepository, delegate: self)
        let todayActivityVC = TodayActivitiesViewController(activityVM: todayActivityVM)
        navigationController.setViewControllers([todayActivityVC], animated: false)
    }
    
    deinit {
        print("TodayCoordinator deinit")
    }
}

extension TodayCoordinator: TodayActivityVMDelegate {
    func showTypeManager() {
        let coordinator = TypeManagerCoordinator(navigationController: navigationController, activityTypeRepository: activityTypeRepository)
        coordinator.start()
    }
    
    func showHistory() {
        let historyCoordinator = HistoryCoordinator(navigationController: navigationController, activityTypeRepository: activityTypeRepository, activityRepository: activityRepository)
        historyCoordinator.start()
    }
}

//
//  DayActivityCoordinator.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 05.08.2024.
//

import UIKit

final class DayActivityCoordinator: Coordinator {
    let navigationController: UINavigationController
    let activityTypeRepository: ActivityTypeReadableRepository & ActivityTypeWritableRepository
    let activityRepository: ActivityReadableRepository & ActivityWritableRepository
    let date: Date
    
    init(navigationController: UINavigationController, 
         date: Date, 
         activityTypeRepository: (ActivityTypeReadableRepository & ActivityTypeWritableRepository)? = nil,
         activityRepository: (ActivityReadableRepository & ActivityWritableRepository)? = nil
    ) {
        self.date = date
        self.navigationController = navigationController
        
        if let activityTypeRepository {
            self.activityTypeRepository = activityTypeRepository
        } else {
            self.activityTypeRepository = ActivityTypeCoreDataRepository(context: CoreDataManager.shared.backgroundContext)
        }
        
        if let activityRepository {
            self.activityRepository = activityRepository
        } else {
            self.activityRepository = ActivityCoreDataRepository(context: CoreDataManager.shared.backgroundContext)
        }
    }
    
    func start() {
        Task {
            let dayActivityVM = DayActivityVM(activityRepository: activityRepository, typeRepository: activityTypeRepository, delegate: self, date: date)
            let dayActivityVC = await DayActivitiesViewController(activityVM: dayActivityVM)
            if date.isSameDay(with: .now) {
                await navigationController.setViewControllers([dayActivityVC], animated: false)
            } else {
                await navigationController.pushViewController(dayActivityVC, animated: true)
            }
        }
    }
    
    deinit {
        print("DayActivityCoordinator deinit")
    }
}

extension DayActivityCoordinator: DayActivityVMDelegate {
    func showTypeManager() {
            let coordinator = TypeManagerCoordinator(navigationController: navigationController, activityTypeRepository: activityTypeRepository)
            coordinator.start()
    }
    
    func showHistory() {
        guard let historyRepository = activityRepository as? HistoryRepository & ActivityReadableRepository else { return }
        let historyCoordinator = HistoryCoordinator(navigationController: navigationController, activityTypeRepository: activityTypeRepository, activityRepository: historyRepository)
        historyCoordinator.start()
    }
}

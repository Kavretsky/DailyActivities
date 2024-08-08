//
//  TypeManagerCoordinator.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 05.08.2024.
//
import UIKit

final class TypeManagerCoordinator: Coordinator {
    private var navigationController: UINavigationController
    private let activityTypeRepository: ActivityTypeReadableRepository & ActivityTypeWritableRepository
    
    init(navigationController: UINavigationController, activityTypeRepository: ActivityTypeReadableRepository & ActivityTypeWritableRepository) {
        self.navigationController = navigationController
        self.activityTypeRepository = activityTypeRepository
    }
    
    func start() {
        let typeManagerVM = TypeManagerVM(activityTypeRepository: activityTypeRepository)
        let typeManagerVC = TypeManagerTableViewController(typeRepository: typeManagerVM)
        let typeManagerNC = UINavigationController(rootViewController: typeManagerVC)
        typeManagerNC.modalPresentationStyle = .fullScreen
        navigationController.present(typeManagerNC, animated: true)
    }
    
    deinit {
        print("TypeManagerCoordinator deinited")
    }
}

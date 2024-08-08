//
//  AppCoordinator.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 05.08.2024.
//

import UIKit

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let activityCoordinator = TodayCoordinator(navigationController: navigationController)
        activityCoordinator.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

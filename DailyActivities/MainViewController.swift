//
//  MainViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 11.08.2023.
//

import UIKit

class MainViewController: UIViewController {
    
//    private var typeChangeButton: UIButton = UIButton(type: .custom)
//    private var descriptionTF: UITextField = UITextField()
//    private var controlsHStack: UIStackView = UIStackView()
//    private var newActivityButton = UIButton()
//    private var newActivitySV = UIStackView()
    
    private var newActivityView = NewActivityVIew()
    
    var activityType: ActivityType = ActivityType.sample()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(newActivityView)
        NSLayoutConstraint.activate([
            newActivityView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            newActivityView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            newActivityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newActivityView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        newActivityView.updateConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        newActivityView.setupUI()
        NSLayoutConstraint.activate([
            newActivityView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            newActivityView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            newActivityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newActivityView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        newActivityView.updateConstraints()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = .cyan
    }
    
    

}

struct ActivityType {
    var emoji: String
    var color: UIColor
    var description: String
    
    static func sample() -> ActivityType {
        ActivityType(emoji: "🪿", color: .magenta, description: "Goose activity")
    }
}

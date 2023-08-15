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
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
            view.endEditing(true) // Этот метод скрывает клавиатуру
        }
    
    private func setupUI() {
        view.addSubview(newActivityView)
//        NSLayoutConstraint.activate([
//            newActivityView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            newActivityView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
////            newActivityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            newActivityView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
        newActivityView.updateConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate([
            newActivityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newActivityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newActivityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newActivityView.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor),
            newActivityView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            
//            newActivityView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
//            newActivityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            newActivityView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom),
//            newActivityView.heightAnchor.constraint(equalToConstant: 140)
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

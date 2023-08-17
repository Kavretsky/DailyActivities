//
//  MainViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 11.08.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    private let typeStore: TypeStore
    private let newActivityView: NewActivityView
    
    init(typeStore: TypeStore) {
        self.typeStore = typeStore
        newActivityView = NewActivityView(typeStore: self.typeStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        newActivityView.delegate = self
        title = "Today"
    }
    
    @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
    
    private func setupUI() {
        view.addSubview(newActivityView)
        newActivityView.updateConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate([
            newActivityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newActivityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newActivityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newActivityView.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor),
//            newActivityView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
//            newActivityView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
//            newActivityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            newActivityView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom),
//            newActivityView.heightAnchor.constraint(equalToConstant: 140)
        ])
        newActivityView.updateConstraints()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = .white
    }
    
}

extension MainViewController: NewActivityViewDelegate {
    func showTypeManager() {
        let typeManagerVC = TypeManagerViewController()
        let typeManagerNC = UINavigationController(rootViewController: typeManagerVC)
        typeManagerVC.title = "Type manager"
        self.present(typeManagerNC, animated: true)
    }
    
    
}

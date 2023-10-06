//
//  MainViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 11.08.2023.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    
    
    private let typeStore: TypeStore
    private let activityStore: ActivityStore
    private let createActivityView: NewActivityView
    private let activityListDate: Date
    
    private let activitiesTableView = UITableView(frame: .zero)

    
    init(typeStore: TypeStore, activityStore: ActivityStore) {
        self.activityStore = activityStore
        self.typeStore = typeStore
        activityListDate = .now
        createActivityView = NewActivityView(typeStore: self.typeStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivitiesTableview()
        
    }
    
    @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
    
    private func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        createActivityView.delegate = self
        title = "Today"
        view.addSubview(activitiesTableView)
        view.addSubview(createActivityView)
        createActivityView.updateConstraints()
        activitiesTableView.register(ActivittiesTableViewCell.self, forCellReuseIdentifier: "ActivityTableViewCellIdentifier")
    }
    
    private func setupActivitiesTableview() {
        activitiesTableView.translatesAutoresizingMaskIntoConstraints = false 
        activitiesTableView.dataSource = self
        activitiesTableView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate([
            createActivityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createActivityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createActivityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            createActivityView.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor),
            
            activitiesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            activitiesTableView.bottomAnchor.constraint(lessThanOrEqualTo: createActivityView.topAnchor),
            activitiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activitiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        

    }


    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = .white
    }
    
    
    
}

extension MainViewController: NewActivityViewDelegate {
    func showTypeManager() {
        let typeManagerVC = TypeManagerTableViewController(typeStore: typeStore)
        let typeManagerNC = UINavigationController(rootViewController: typeManagerVC)
        self.present(typeManagerNC, animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityStore.activities(for: activityListDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCellIdentifier", for: indexPath)
        let activity = activityStore.activities(for: activityListDate)[indexPath.row]
//        cell.activityDescription = activity.name
        var cellConfiguration = UIListContentConfiguration.cell()
        cellConfiguration.text = activity.name
        cell.contentConfiguration = cellConfiguration
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
}

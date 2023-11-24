//
//  MainViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 11.08.2023.
//

import UIKit
//import Combine

final class MainViewController: UIViewController {
    private let typeStore: TypeStore
    private let activityStore: ActivityStore
    private let createActivityView: NewActivityView
    private let activityListDate: Date
    
    private let activitiesTableView = UITableView(frame: .zero, style: .insetGrouped)

    
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
        createActivityView.delegate = self
        title = "Today"
        view.addSubview(activitiesTableView)
        view.addSubview(createActivityView)
        createActivityView.updateConstraints()
    }
    
    private func setupActivitiesTableview() {
        activitiesTableView.translatesAutoresizingMaskIntoConstraints = false 
        activitiesTableView.delegate = self
        activitiesTableView.dataSource = self
        activitiesTableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityTableViewCellIdentifier")
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
    func addNewActivity(description: String, typeID: String) {
        activityStore.addActivity(description: description, typeID: typeID)
        activitiesTableView.beginUpdates()
        let indexPath = IndexPath(item: activityStore.activities(for: activityListDate).count - 1, section: 0)
        activitiesTableView.insertRows(at: [indexPath], with: .automatic)
        activitiesTableView.endUpdates()
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCellIdentifier", for: indexPath) as! ActivityTableViewCell
        let activity = activityStore.activities(for: activityListDate)[indexPath.row]
        if activity.finishDateTime != nil {
            cell.duration = "\(activity.startDateTime.formatted(date: .omitted, time: .shortened)) — \(activity.finishDateTime!.formatted(date: .omitted, time: .shortened))"
        } else {
            cell.duration = "Started at \(activity.startDateTime.formatted(date: .omitted, time: .shortened))"
            
        }
        cell.activityDescription = activity.description
        cell.typeEmoji = typeStore.type(withID: activity.typeID).emoji
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Activities"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        let activityEditVC = ActivityEditTableViewController(types: typeStore.activeTypes, activity: activityStore.activities(for: activityListDate)[indexPath.row])
        activityEditVC.delegate = self
        activityEditVC.isModalInPresentation = true
        let activityEditNC = UINavigationController(rootViewController: activityEditVC)
        self.present(activityEditNC, animated: true)
    }
}

extension MainViewController: ActivityEditTableViewControllerDelegate {
    func deleteActivity(_ activity: Activity) {
        if let indexPath = activitiesTableView.indexPathsForSelectedRows {
            activitiesTableView.beginUpdates()
            activitiesTableView.deleteRows(at: indexPath, with: .automatic)
            activityStore.deleteActivity(activity)
            activitiesTableView.endUpdates()
        }
    }
    
    func updateActivity(_ activity: Activity, with data: Activity.Data) {
        if let indexPath = activitiesTableView.indexPathsForSelectedRows {
            activitiesTableView.beginUpdates()
            activitiesTableView.reloadRows(at: indexPath, with: .automatic)
            activityStore.updateActivity(activity, with: data)
            activitiesTableView.endUpdates()
        }
    }
    
    func cancelButtonTapped() {
        if let indexPath = activitiesTableView.indexPathForSelectedRow {
            activitiesTableView.beginUpdates()
            activitiesTableView.deselectRow(at: indexPath, animated: true)
            
            activitiesTableView.endUpdates()
//            print(activityStore.activities(for: .now))
        }
    }
    
    
}

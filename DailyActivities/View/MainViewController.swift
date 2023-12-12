//
//  MainViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 11.08.2023.
//

import UIKit
import SwiftUI

final class MainViewController: UIViewController {
    private let typeStore: TypeStore
    private let activityStore: ActivityStore
    private let newActivityView: NewActivityView
    private let activityListDate: Date
    private var lastSelectedIndexPath: IndexPath?
    
    private lazy var activitiesTableView = UITableView(frame: .zero, style: .insetGrouped)

    private let deleteActivityAlert: UIAlertController = {
        let sheetAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        return sheetAlert
    }()
    
    private let emptyPlaceholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("There are no logged activities today.\nLet's start log your day below.", comment: "placeholder when there are no activities per day")
        label.font = .systemFont(ofSize: 17)
        label.tintColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private enum Section: Int {
        case Chart
        case Activities
    }
    
    init(typeStore: TypeStore, activityStore: ActivityStore) {
        self.activityStore = activityStore
        self.typeStore = typeStore
        activityListDate = .now
        newActivityView = NewActivityView(typeStore: self.typeStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivitiesTableview()
        setupDeleteActivityAlert()
        print (Section.Chart.rawValue, Section.Activities.rawValue)
    }
    
    @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
    
    private func setupUI() {
        newActivityView.delegate = self
        title = "Today"
        view.addSubview(activitiesTableView)
        view.addSubview(newActivityView)
        view.addSubview(emptyPlaceholder)
        activitiesTableView.keyboardDismissMode = .interactive
        if activityStore.activities(for: activityListDate).isEmpty {
            activitiesTableView.isHidden = true
        } else {
            emptyPlaceholder.isHidden = true
        }
        newActivityView.updateConstraints()
    }
    
    private func setupActivitiesTableview() {
        activitiesTableView.translatesAutoresizingMaskIntoConstraints = false 
        activitiesTableView.delegate = self
        activitiesTableView.dataSource = self
        activitiesTableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityTableViewCellIdentifier")
        activitiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ActivityChartTableViewCellIdentifier")
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        NSLayoutConstraint.activate([
            newActivityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newActivityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.keyboardLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: newActivityView.bottomAnchor),
            
            activitiesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            activitiesTableView.bottomAnchor.constraint(equalTo: newActivityView.topAnchor),
            activitiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activitiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emptyPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emptyPlaceholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholder.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        ])
        
        let dismissPadding = newActivityView.bounds.height
        newActivityView.keyboardLayoutGuide.keyboardDismissPadding = dismissPadding
    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = .tertiarySystemGroupedBackground
    }
    
    private func setupDeleteActivityAlert() {
        let confirmDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] handler in
            self?.deleteActivityButtonTapped()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        deleteActivityAlert.addAction(confirmDeleteAction)
        deleteActivityAlert.addAction(cancel)
    }
    
    private func showDeleteActivityAlert() {
        guard let index = lastSelectedIndexPath else { return }
        let activityToDelete = activityStore.activities(for: activityListDate)[index.row]
        deleteActivityAlert.title = activityToDelete.description
        self.present(deleteActivityAlert, animated: true)
        
    }
    
    private func deleteActivityButtonTapped() {
        guard let index = lastSelectedIndexPath else { return }
        let activity = activityStore.activities(for: activityListDate)[index.row]
        self.deleteActivity(activity)
    }
    
    private func finishActivity(_ activity: Activity, at indexPath: IndexPath) {
        var data = activity.data
        data.finishDateTime = .now
        DispatchQueue.global().async {
            self.activityStore.updateActivity(activity, with: data)
        }
        activitiesTableView.beginUpdates()
        activitiesTableView.reloadRows(at: [indexPath], with: .none)
        activitiesTableView.endUpdates()
    }
    
}

extension MainViewController: NewActivityViewDelegate {
    func addNewActivity(description: String, typeID: String) {
        if activitiesTableView.isHidden {
            self.emptyPlaceholder.isHidden = true
            self.activitiesTableView.isHidden = false
        }
        activityStore.addActivity(description: description, typeID: typeID)
        let indexPath = IndexPath(item: activityStore.activities(for: activityListDate).count - 1, section: 1)
        activitiesTableView.beginUpdates()
        if activityStore.activities(for: activityListDate).count > 1 {
            activitiesTableView.reloadRows(at: [IndexPath(row: indexPath.row - 1, section: indexPath.section)], with: .none)
        }
        activitiesTableView.insertRows(at: [indexPath], with: .fade)
        activitiesTableView.endUpdates()
        activitiesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func showTypeManager() {
        let typeManagerVC = TypeManagerTableViewController(typeStore: typeStore)
        let typeManagerNC = UINavigationController(rootViewController: typeManagerVC)
        self.present(typeManagerNC, animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? activityStore.activities(for: activityListDate).count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityChartTableViewCellIdentifier")!
            cell.contentConfiguration = UIHostingConfiguration(content: {
                DayActivityChart(activities: activityStore.activities(for: activityListDate), typeStore: typeStore)
            })
            return cell
        case (1, _):
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
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Activities" : nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        lastSelectedIndexPath = indexPath
        let activityEditVC = ActivityEditTableViewController(types: typeStore.activeTypes, activity: activityStore.activities(for: activityListDate)[indexPath.row])
        activityEditVC.delegate = self
        activityEditVC.isModalInPresentation = true
        let activityEditNC = UINavigationController(rootViewController: activityEditVC)
        self.present(activityEditNC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, view, handler) in
            self.lastSelectedIndexPath = indexPath
            self.showDeleteActivityAlert()
            handler(true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        deleteAction.image = UIImage(systemName: "trash")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let activity = activityStore.activities(for: activityListDate)[indexPath.row]
        if activity.finishDateTime == nil {
            let completeActivity = UIContextualAction(style: .normal, title: "Complete") { [weak self] (action, view, completionHandler) in
                self?.finishActivity(activity, at: indexPath)
                completionHandler(true)
            }
            completeActivity.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [completeActivity])
        } else {
            let startActivityAgain = UIContextualAction(style: .normal, title: "Start again") { [weak self] (action, view, completionHandler) in
                self?.addNewActivity(description: activity.description, typeID: activity.typeID)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [startActivityAgain])
        }
    }
}

extension MainViewController: ActivityEditTableViewControllerDelegate {
    func deleteActivity(_ activity: Activity) {
        if let indexPath = lastSelectedIndexPath {
            activitiesTableView.beginUpdates()
            activitiesTableView.deleteRows(at: [indexPath], with: .automatic)
            activityStore.deleteActivity(activity)
            activitiesTableView.endUpdates()
            if activityStore.activities(for: activityListDate).isEmpty {
                activitiesTableView.isHidden = true
                emptyPlaceholder.isHidden = false
            }
        }
    }
    
    func updateActivity(_ activity: Activity, with data: Activity.Data) {
        if let indexPath = activitiesTableView.indexPathsForSelectedRows {
            activitiesTableView.beginUpdates()
            DispatchQueue.global().async {
                self.activityStore.updateActivity(activity, with: data)
            }
            activitiesTableView.reloadRows(at: indexPath, with: .automatic)
            activitiesTableView.endUpdates()
        }
    }
    
    func cancelButtonTapped() {
        if let indexPath = activitiesTableView.indexPathForSelectedRow {
            activitiesTableView.beginUpdates()
            activitiesTableView.deselectRow(at: indexPath, animated: true)
            activitiesTableView.endUpdates()
        }
        lastSelectedIndexPath = nil
    }
}

#Preview("Main") {
    let activityStore = ActivityStore()
    let typeStore = TypeStore()
    let controller = MainViewController(typeStore: typeStore, activityStore: activityStore)
    return UINavigationController(rootViewController: controller)
}

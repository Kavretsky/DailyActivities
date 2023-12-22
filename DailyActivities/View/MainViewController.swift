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
    
    private lazy var activityTableView = UITableView(frame: .zero, style: .insetGrouped)

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
    
    enum Section: Int, CaseIterable, Hashable {
        case chart
        case activities
        
        var header: String? {
            switch self {
            case .chart:
                return nil
            case .activities:
                return "Activities"
            }
        }
    }
    
    private lazy var dataSource: ActivityTableViewDiffableDataSource = makeDataSource()
//    private var snapshot: NSDiffableDataSourceSnapshot<Section, AnyHashable>!
    
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
        updateActivityTableView()
        dataSource.defaultRowAnimation = .fade
    }
    
    @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
    
    private func setupUI() {
        newActivityView.delegate = self
        title = "Today"
        view.addSubview(activityTableView)
        view.addSubview(newActivityView)
        view.addSubview(emptyPlaceholder)
        activityTableView.keyboardDismissMode = .interactive
        if activityStore.activities(for: activityListDate).isEmpty {
            activityTableView.isHidden = true
        } else {
            emptyPlaceholder.isHidden = true
        }
        newActivityView.updateConstraints()
    }
    
    private func setupActivitiesTableview() {
        activityTableView.translatesAutoresizingMaskIntoConstraints = false 
        activityTableView.delegate = self
//        activitiesTableView.dataSource = self
        activityTableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityTableViewCellIdentifier")
        activityTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ActivityChartTableViewCellIdentifier")
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        NSLayoutConstraint.activate([
            newActivityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newActivityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.keyboardLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: newActivityView.bottomAnchor),
            
            activityTableView.topAnchor.constraint(equalTo: view.topAnchor),
            activityTableView.bottomAnchor.constraint(equalTo: newActivityView.topAnchor),
            activityTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
    
    private func makeDataSource() -> ActivityTableViewDiffableDataSource {
        return ActivityTableViewDiffableDataSource(tableView: activityTableView) { [weak self] tableView, indexPath, item in
            guard let self else { return nil }
            guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
            switch section {
            case .chart:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityChartTableViewCellIdentifier")!
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    DayActivityChart(activityStore: self.activityStore, typeStore: self.typeStore)
                })
                return cell
            case .activities:
                guard let activity = item as? Activity else { return nil }
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCellIdentifier", for: indexPath) as! ActivityTableViewCell
                if activity.finishDateTime != nil {
                    cell.duration = "\(activity.startDateTime.formatted(date: .omitted, time: .shortened)) — \(activity.finishDateTime!.formatted(date: .omitted, time: .shortened))"
                } else {
                    cell.duration = "Started at \(activity.startDateTime.formatted(date: .omitted, time: .shortened))"
                    
                }
                cell.activityDescription = activity.description
                cell.typeEmoji = typeStore.type(withID: activity.typeID).emoji
                return cell
            }
        }
    }
    
    private func updateActivityTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(activityStore.activities, toSection: Section.activities)
        snapshot.appendItems(["DayActivityChart"], toSection: Section.chart)
        dataSource.apply(snapshot, animatingDifferences: true)
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
        updateActivity(activity, with: data)
//        activityTableView.beginUpdates()
//        activityTableView.reloadRows(at: [indexPath], with: .none)
//        activityTableView.endUpdates()
    }
    
}

extension MainViewController: NewActivityViewDelegate {
    func addNewActivity(description: String, typeID: String) {
        if activityTableView.isHidden {
            self.emptyPlaceholder.isHidden = true
            self.activityTableView.isHidden = false
        }
        activityStore.addActivity(description: description, typeID: typeID)
        updateActivityTableView()
//        snapshot.appendItems([activityStore.activities.last], toSection: .activities)
//        dataSource.apply(snapshot, animatingDifferences: true)
//        let indexPath = IndexPath(item: activityStore.activities(for: activityListDate).count - 1, section: Section.activities.rawValue)
//        activityTableView.beginUpdates()
//        if activityStore.activities(for: activityListDate).count > 1 {
//            activityTableView.reloadRows(at: [IndexPath(row: indexPath.row - 1, section: indexPath.section)], with: .none)
//        }
//        activityTableView.insertRows(at: [indexPath], with: .fade)
//        activityTableView.endUpdates()
//        activityTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func showTypeManager() {
        let typeManagerVC = TypeManagerTableViewController(typeStore: typeStore)
        let typeManagerNC = UINavigationController(rootViewController: typeManagerVC)
        self.present(typeManagerNC, animated: true)
    }
}

//extension MainViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch Section(rawValue: section) {
//        case .activities: return activityStore.activities(for: activityListDate).count
//        case .chart: return 1
//        case .none: return 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
//        switch section {
//        case .chart:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityChartTableViewCellIdentifier")!
//            cell.contentConfiguration = UIHostingConfiguration(content: {
//                DayActivityChart(activityStore: activityStore, typeStore: typeStore)
//            })
//            return cell
//        case .activities:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCellIdentifier", for: indexPath) as! ActivityTableViewCell
//            let activity = activityStore.activities(for: activityListDate)[indexPath.row]
//            if activity.finishDateTime != nil {
//                cell.duration = "\(activity.startDateTime.formatted(date: .omitted, time: .shortened)) — \(activity.finishDateTime!.formatted(date: .omitted, time: .shortened))"
//            } else {
//                cell.duration = "Started at \(activity.startDateTime.formatted(date: .omitted, time: .shortened))"
//                
//            }
//            cell.activityDescription = activity.description
//            cell.typeEmoji = typeStore.type(withID: activity.typeID).emoji
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return Section(rawValue: section)?.header
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return Section.allCases.count
//    }
//    
//}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .activities else { return }
        dismissKeyboard()
        lastSelectedIndexPath = indexPath
        let activityEditVC = ActivityEditTableViewController(types: typeStore.activeTypes, activity: activityStore.activities(for: activityListDate)[indexPath.row])
        activityEditVC.delegate = self
        activityEditVC.isModalInPresentation = true
        let activityEditNC = UINavigationController(rootViewController: activityEditVC)
        self.present(activityEditNC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .activities else { return nil }
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
        guard Section(rawValue: indexPath.section) == .activities else { return nil }
        lastSelectedIndexPath = indexPath
        print(indexPath)
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return Section(rawValue: indexPath.section) == .activities ? indexPath : nil
    }
}

extension MainViewController: ActivityEditTableViewControllerDelegate {
    func deleteActivity(_ activity: Activity) {
        if let indexPath = lastSelectedIndexPath {
//            activityTableView.beginUpdates()
//            activityTableView.deleteRows(at: [indexPath], with: .automatic)
            activityStore.deleteActivity(activity)
//            activityTableView.endUpdates()
            updateActivityTableView()
            if activityStore.activities(for: activityListDate).isEmpty {
                activityTableView.isHidden = true
                emptyPlaceholder.isHidden = false
            }
        }
    }
    
    func updateActivity(_ activity: Activity, with data: Activity.Data) {
        if let indexPath = lastSelectedIndexPath {
            print(indexPath)
            print("update \(activity) with \(data)")
//            activityTableView.beginUpdates()
            activityStore.updateActivity(activity, with: data)
            updateActivityTableView()
//            snapshot.reconfigureItems([activityStore.activities[activity]])
            
//            dataSource.defaultRowAnimation = .fade
//            dataSource.apply(snapshot, animatingDifferences: true)
//            activityTableView.reloadRows(at: indexPath, with: .automatic)
//            activityTableView.endUpdates()
        }
    }
    
    func cancelButtonTapped() {
        if let indexPath = activityTableView.indexPathForSelectedRow {
            activityTableView.beginUpdates()
            activityTableView.deselectRow(at: indexPath, animated: true)
            activityTableView.endUpdates()
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

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
    private var isSwipeActionsShow = false
    
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
    private var snapshot: NSDiffableDataSourceSnapshot<Section, AnyHashable>!
    
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
        configureSnapshot()
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
        if activityStore.activities(for: activityListDate).isEmpty {
            activityTableView.isHidden = true
        } else {
            emptyPlaceholder.isHidden = true
        }
        newActivityView.updateConstraints()
    }
    
    private func setupActivitiesTableview() {
        activityTableView.keyboardDismissMode = .interactive
        activityTableView.translatesAutoresizingMaskIntoConstraints = false
        activityTableView.delegate = self
        activityTableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityTableViewCellIdentifier")
        activityTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ActivityChartTableViewCellIdentifier")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        activityTableView.addGestureRecognizer(tapGesture)
        
        dataSource.defaultRowAnimation = .fade
    }
    
    @objc private func handleCellTap(_ gesture: UITapGestureRecognizer) {
        guard let indexPath = activityTableView.indexPathForRow(at: gesture.location(in: activityTableView)) else { return }

        if isSwipeActionsShow && activityTableView.isEditing {
            isSwipeActionsShow = false
        } else {
            tableView(activityTableView, didSelectRowAt: indexPath)
        }
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
            guard let self else { return .init() }
            guard let section = Section(rawValue: indexPath.section) else { return .init() }
            switch section {
            case .chart:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityChartTableViewCellIdentifier")!
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    DayActivityChart(activityStore: self.activityStore, typeStore: self.typeStore)
                })
//                cell.selectionStyle = .none
                return cell
            case .activities:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCellIdentifier", for: indexPath) as! ActivityTableViewCell
                guard let activity = activityStore.activities.first(where: {$0.id == item as! String}) else {
                    return cell
                }
                var durationString = ""
                if activity.finishDateTime != nil {
                    durationString = "\(activity.startDateTime.formatted(date: .omitted, time: .shortened)) — \(activity.finishDateTime!.formatted(date: .omitted, time: .shortened))"
                } else {
                    durationString = "Started at \(activity.startDateTime.formatted(date: .omitted, time: .shortened))"
                    
                }
                
                var durationAttributedString: NSMutableAttributedString
                let isConflict = activityStore.conflictActivityDictionary.values.contains(where: {$0.contains(activity.id) }) || activityStore.conflictActivityDictionary.keys.contains(activity.id)
                
                if isConflict {
                    durationString = "Conflict  " + durationString
                    durationAttributedString = .init(string: durationString)
                    durationAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 1, green: 0.176, blue: 0.333, alpha: 1), range: .init(location: 0, length: 10))
                    durationAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1), range: .init(location: 10, length: durationAttributedString.length - 10))
                } else {
                    durationAttributedString = .init(string: durationString)
                    durationAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1), range: .init(location: 0, length: durationAttributedString.length))
                }
                durationAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 11), range: .init(location: 0, length: durationAttributedString.length))
                
                cell.duration = durationAttributedString
                cell.activityDescription = activity.description
                cell.typeEmoji = typeStore.type(withID: activity.typeID).emoji
//                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    private func configureSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(activityStore.activities.map{$0.id}, toSection: Section.activities)
        snapshot.appendItems(["DayActivityChart"], toSection: Section.chart)
        DispatchQueue.global().async { [unowned self] in
            dataSource.apply(snapshot, animatingDifferences: true)
        }
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
    }
    
}

extension MainViewController: NewActivityViewDelegate {
    func addNewActivity(description: String, typeID: String) {
        if activityTableView.isHidden {
            self.emptyPlaceholder.isHidden = true
            self.activityTableView.isHidden = false
        }
        if let lastActivity = activityStore.activities.last, lastActivity.finishDateTime == nil {
            snapshot.reconfigureItems([activityStore.activities.last?.id])
        }
        activityStore.addActivity(description: description, typeID: typeID)
        dataSource.defaultRowAnimation = activityStore.activities.count != 1 ? .top : .fade
        snapshot.appendItems([activityStore.activities.last?.id], toSection: .activities)
        DispatchQueue.global().async { [unowned self] in
            dataSource.apply(snapshot)
            let indexPath = IndexPath(row: snapshot.numberOfItems(inSection: .activities) - 1, section: Section.activities.rawValue)
            DispatchQueue.main.async { 
                self.activityTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func showTypeManager() {
        let typeManagerVC = TypeManagerTableViewController(typeStore: typeStore)
        typeManagerVC.delegate = self
        print(typeManagerVC.delegate != nil)
        let typeManagerNC = UINavigationController(rootViewController: typeManagerVC)
        self.present(typeManagerNC, animated: true)
    }
}

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
        lastSelectedIndexPath = indexPath
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
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        isSwipeActionsShow = true
    }
}

extension MainViewController: ActivityEditTableViewControllerDelegate {
    func deleteActivity(_ activity: Activity) {
        if lastSelectedIndexPath != nil {
            DispatchQueue.global().async { [unowned self] in
                dataSource.defaultRowAnimation = activityStore.activities.index(matching: activity) != 0 ? .top : .bottom
                snapshot.deleteItems([activity.id])
                dataSource.apply(snapshot, animatingDifferences: true)
                activityStore.deleteActivity(activity)
                if activityStore.activities(for: activityListDate).isEmpty {
                    DispatchQueue.main.async {
                        self.activityTableView.isHidden = true
                        self.emptyPlaceholder.isHidden = false
                    }
                }
                
                snapshot.reconfigureItems(activityStore.activitiesToReconfigure)
                
                dataSource.apply(snapshot, animatingDifferences: true)
                
            }
            
        }
    }
    
    func updateActivity(_ activity: Activity, with data: Activity.Data) {
//        dataSource.defaultRowAnimation = .fade
        let activityIndexBeforeUpdate = activityStore.activities.index(matching: activity)
        activityStore.updateActivity(activity, with: data)
        let activityIndexAfterUpdate = activityStore.activities.index(matching: activity)
        if activityIndexBeforeUpdate != activityIndexAfterUpdate {
            if activityIndexAfterUpdate == activityStore.activities.count - 1 {
                snapshot.moveItem(activity.id, afterItem: activityStore.activities[activityIndexAfterUpdate! - 1].id)
            } else {
                snapshot.moveItem(activity.id, beforeItem: activityStore.activities[activityIndexAfterUpdate! + 1].id)
            }
        }
        snapshot.reconfigureItems([activity.id])
        snapshot.reconfigureItems(activityStore.activitiesToReconfigure)
        DispatchQueue.global().async {
            self.dataSource.apply(self.snapshot, animatingDifferences: true)
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

extension MainViewController: TypeManagerTableViewControllerDelegate {
    func activityTypesChanged() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            self.snapshot.reconfigureItems(self.activityStore.activities.map { $0.id })
            DispatchQueue.main.async {
                self.dataSource.apply(self.snapshot)
            }
        }
    }
}

#Preview("Main") {
    let activityStore = ActivityStore()
    let typeStore = TypeStore()
    let controller = MainViewController(typeStore: typeStore, activityStore: activityStore)
    return UINavigationController(rootViewController: controller)
}

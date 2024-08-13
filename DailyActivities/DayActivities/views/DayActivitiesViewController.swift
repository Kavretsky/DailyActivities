//
//  DayActivitiesViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 11.08.2023.
//

import UIKit
import SwiftUI
import Combine
import Collections

final class DayActivitiesViewController: UIViewController {
    private let dayActivityVM: DayActivityVM
    private let newActivityView: NewActivityView
    private var lastSelectedIndexPath: IndexPath?
    private var isSwipeActionsShow = false
    private let mutex = NSLock()
    private lazy var activityTableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var deleteActivityAlert: UIAlertController = {
        let sheetAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        return sheetAlert
    }()
    private let queue = DispatchQueue(label: "applyDatasource", target: .global(qos: .userInitiated))
    
    private lazy var emptyPlaceholder: UIView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("There are no logged activities today.\nLet's start log your day below.", comment: "placeholder when there are no activities per day")
        label.font = .systemFont(ofSize: 17)
        label.tintColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        let view = UIView()
        view.addSubview(label)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private lazy var activityEditVC: ActivityEditTableViewController = {
        let activityEditVC = ActivityEditTableViewController()
        activityEditVC.delegate = self
        return activityEditVC
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
    
    private var cancellables = Set<AnyCancellable>()
    
    init(activityVM: DayActivityVM) {
        self.dayActivityVM = activityVM
        newActivityView = NewActivityView(types: activityVM.activeTypes.elements)
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
        if dayActivityVM.date.isSameDay(with: .now) {
            setupNavBar()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupConstrains() {
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
            emptyPlaceholder.topAnchor.constraint(equalTo: view.topAnchor),
            emptyPlaceholder.bottomAnchor.constraint(equalTo: newActivityView.topAnchor)            
        ])
        
        view.keyboardLayoutGuide.keyboardDismissPadding = 52
    }
    
    private func setupNavBar() {
        let leftBarButtonAction = UIAction { [weak self] _ in
            Task {
                await self?.showHistory()
            }
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "History", primaryAction: leftBarButtonAction)
    }
    
    private func setupUI() {
        view.backgroundColor = .tertiarySystemGroupedBackground
        newActivityView.delegate = self
        if dayActivityVM.date.isSameDay(with: .now) {
            title = "Today"
        } else {
            title = dayActivityVM.date.formatted(.dateTime.month(.wide).day())
        }
        view.addSubview(activityTableView)
        view.addSubview(newActivityView)
        view.addSubview(emptyPlaceholder)
        showEmptyViewIfNeeded()
        setupConstrains()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func showEmptyViewIfNeeded() {
        activityTableView.isHidden = dayActivityVM.activities.isEmpty
        emptyPlaceholder.isHidden = !dayActivityVM.activities.isEmpty
    }
    
    private func setupActivitiesTableview() {
        activityTableView.keyboardDismissMode = .interactive
        activityTableView.translatesAutoresizingMaskIntoConstraints = false
        activityTableView.delegate = self
        activityTableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityTableViewCellIdentifier")
        activityTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ActivityChartTableViewCellIdentifier")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        activityTableView.addGestureRecognizer(tapGesture)
        
        dataSource.defaultRowAnimation = .automatic
    }
    
    private func setupBindings() {
        dayActivityVM.$activities
            .receive(on: DispatchQueue.global())
            .map({ $0.map({$0.id}) })
            .sink { [weak self] activitiesID in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.showEmptyViewIfNeeded()
                }
                guard !activitiesID.isEmpty else { return }
                queue.async(flags: .barrier) {
                    var newSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                    newSnapshot.appendSections(Section.allCases)
                    newSnapshot.appendItems(activitiesID, toSection: Section.activities)
                    newSnapshot.appendItems(["DayActivityChart"], toSection: Section.chart)
                    self.dataSource.apply(newSnapshot, animatingDifferences: true)
                    if self.snapshot.itemIdentifiers.count < newSnapshot.itemIdentifiers.count {
                        DispatchQueue.main.async {
                            self.activityTableView.scrollToRow(at: IndexPath(row: activitiesID.count - 1, section: 1), at: .top, animated: true)
                        }
                    }
                    
                    self.snapshot = newSnapshot
                }
            }
            .store(in: &cancellables)
        
        dayActivityVM.$activitiesToReconfigure
            .receive(on: queue)
            .sink { [weak self] activitiesID in
                guard !activitiesID.isEmpty else { return }
                guard let self else { return }
                
                queue.async {
                    var newSnapshot = self.dataSource.snapshot()
                    newSnapshot.reconfigureItems(activitiesID.map { $0 })
                    self.dataSource.apply(newSnapshot, animatingDifferences: true)
                }

            }
            .store(in: &cancellables)
        
        dayActivityVM.$activeTypes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] types in
                guard let self else { return }
                self.newActivityView.reconfigure(with: types.elements)
                queue.async {
                    var newSnapshot = self.dataSource.snapshot()
                    newSnapshot.reconfigureItems(["DayActivityChart"])
                    newSnapshot.reconfigureItems(newSnapshot.itemIdentifiers(inSection: .activities))
                    self.dataSource.apply(newSnapshot)
                }
            }
            .store(in: &cancellables)
        
        dayActivityVM.$chartData
            .receive(on: queue)
            .sink { [weak self] _ in
                guard let self else { return }
                queue.async {
                    var newSnapshot = self.dataSource.snapshot()
                    newSnapshot.reconfigureItems(["DayActivityChart"])
                    self.dataSource.apply(newSnapshot)
                }
            }
            .store(in: &cancellables)
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
        queue.async { [unowned self] in
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.forEach { $0.cancel() }
    }
    
    private func makeDataSource() -> ActivityTableViewDiffableDataSource {
        return ActivityTableViewDiffableDataSource(tableView: activityTableView) { [weak self] tableView, indexPath, _ in
            guard let self else { return .init() }
            guard let section = Section(rawValue: indexPath.section) else { return .init() }
            switch section {
            case .chart:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityChartTableViewCellIdentifier", for: indexPath)
                cell.contentConfiguration = UIHostingConfiguration(content: { [weak self] in
                    if self != nil {
                        ActivityChart(chartData: self!.dayActivityVM.chartData)
                    }
                })
                return cell
            case .activities:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCellIdentifier", for: indexPath) as? ActivityTableViewCell 
                else {
                    fatalError("failed to dequeue ActivityTableViewCellIdentifier cell")
                }
                cell.selectionStyle = .none
                
                let activity = dayActivityVM.activities[indexPath.row]
                var durationString = ""
                if activity.finishDateTime != nil {
                    durationString = "\(activity.startDateTime.formatted(date: .omitted, time: .shortened)) — \(activity.finishDateTime!.formatted(date: .omitted, time: .shortened))"
                } else {
                    durationString = "Started at \(activity.startDateTime.formatted(date: .omitted, time: .shortened))"
                    
                }
                
                var durationAttributedString: NSMutableAttributedString
                let isConflict = dayActivityVM.isConflictActivity(with: activity.id)
                if isConflict {
                    durationString = "Conflict  " + durationString
                    durationAttributedString = .init(string: durationString)
                    durationAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 1, green: 0.176, blue: 0.333, alpha: 1), range: .init(location: 0, length: 10))
                    durationAttributedString.addAttribute(.foregroundColor, 
                                                          value: UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1),
                                                          range: .init(location: 10, length: durationAttributedString.length - 10))
                } else {
                    durationAttributedString = .init(string: durationString)
                    durationAttributedString.addAttribute(.foregroundColor, 
                                                          value: UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1),
                                                          range: .init(location: 0, length: durationAttributedString.length))
                }
                durationAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 11), range: .init(location: 0, length: durationAttributedString.length))
                
                cell.duration = durationAttributedString
                cell.activityDescription = activity.description
                cell.typeEmoji = dayActivityVM.typeSet.first(where: { $0.id == activity.typeID })?.emoji ?? "unknown type"
                return cell
            }
        }
    }
    
    private func configureSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(dayActivityVM.activities.map {$0.id}, toSection: Section.activities)
        snapshot.appendItems(["DayActivityChart"], toSection: Section.chart)
    }
    
    private func setupDeleteActivityAlert() {
        let confirmDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteActivityButtonTapped()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        deleteActivityAlert.addAction(confirmDeleteAction)
        deleteActivityAlert.addAction(cancel)
    }
    
    private func showDeleteActivityAlert() {
        guard let index = lastSelectedIndexPath else { return }
        let activityToDelete = dayActivityVM.activities[index.row]
        deleteActivityAlert.title = activityToDelete.description
        self.present(deleteActivityAlert, animated: true)
        
    }
    
    private func deleteActivityButtonTapped() {
        guard let index = lastSelectedIndexPath else { return }
        let activity = dayActivityVM.activities[index.row]
        self.deleteActivity(activity)
    }
    
    private func finishActivity(_ activity: Activity, at indexPath: IndexPath) {
        var data = activity.data
        data.finishDateTime = .now
        updateActivity(activity, with: data)
    }
    
    private func showHistory() async {
        dayActivityVM.showHistory()
    }
    
    deinit {
        print("\(self) deinit")
        cancellables.forEach { $0.cancel() }
    }
}

extension DayActivitiesViewController: NewActivityViewDelegate {
    func addNewActivity(description: String, typeID: String) {
        dayActivityVM.addActivity(description: description, typeID: typeID)
    }
    
    func showTypeManager() {
        dayActivityVM.showTypeManager()
    }
}

extension DayActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .activities else { return }
        dismissKeyboard()
        lastSelectedIndexPath = indexPath
        activityEditVC.setupWith(types: dayActivityVM.activeTypes.elements, activity: dayActivityVM.activities[indexPath.row])
        let activityEditNC = UINavigationController(rootViewController: activityEditVC)
        self.present(activityEditNC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .activities else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (_, _, handler) in
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
        let activity = dayActivityVM.activities[indexPath.row]
        if activity.finishDateTime == nil {
            let completeActivity = UIContextualAction(style: .normal, title: "Complete") { [weak self] (_, _, completionHandler) in
                self?.finishActivity(activity, at: indexPath)
                completionHandler(true)
            }
            completeActivity.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [completeActivity])
        } else {
            let startActivityAgain = UIContextualAction(style: .normal, title: "Start again") { [weak self] (_, _, completionHandler) in
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

extension DayActivitiesViewController: ActivityEditTableViewControllerDelegate {
    func deleteActivity(_ activity: Activity) {
        if lastSelectedIndexPath != nil {
            Task(priority: .userInitiated) {
                await dayActivityVM.deleteActivity(activity)
            }
        }
    }
    
    func updateActivity(_ activity: Activity, with data: Activity.Data) {
        Task(priority: .userInitiated) {
            await dayActivityVM.updateActivity(activity, with: data)
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
    let activityStore = DayActivityVM(activityRepository: ActivityRepositoryMock(), typeRepository: ActivityTypeRepositoryMock(), delegate: DayActivityVMDelegateMock(), date: .now)
    let controller = DayActivitiesViewController(activityVM: activityStore)
    return UINavigationController(rootViewController: controller)
}

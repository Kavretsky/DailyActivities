//
//  ActivityEditTableViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 08.11.2023.
//

import UIKit

protocol ActivityEditTableViewControllerDelegate: AnyObject {
    func updateActivity(_ activity: Activity, with data: Activity.Data)
    func deleteActivity(_ activity: Activity)
    func cancelButtonTapped()
}

final class ActivityEditTableViewController: UITableViewController {
    private let types:[ActivityType]
    private let activity: Activity
    private var activityData: Activity.Data
    {
        willSet{
            navigationItem.rightBarButtonItem?.isEnabled = !newValue.name.isEmpty
        }
    }
    
    weak var delegate: ActivityEditTableViewControllerDelegate?
    
    let deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIButton.Configuration.plain()
        
        deleteButton.configuration = configuration
        deleteButton.tintColor = .red
        deleteButton.setTitle("Delete type", for: .normal)
        
        return deleteButton
    }()
    
    private let deleteActivityAlert: UIAlertController = {
        let sheetAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        return sheetAlert
    }()
    
    init(types: [ActivityType], activity: Activity) {
        self.types = types
        self.activity = activity
        activityData = activity.data
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: "TextViewTableViewCellReuseIdentifier")
        tableView.register(ActivityTypePickerTableViewCell.self, forCellReuseIdentifier: "ActivityTypePickerTableViewCellReuseIdentifier")
        tableView.register(TimeStartTableViewCell.self, forCellReuseIdentifier: "TimeStartTableViewCellReuseIdentifier")
        tableView.register(TimeFinishTableViewCell.self, forCellReuseIdentifier: "TimeFinishTableViewCellReuseIdentifier")
        self.navigationItem.title = "Activity"
        tableView.allowsSelection = false
        setupToolBar()
        setupDeleteButton()
        setupDeleteActivityAlert()
    }
    
    private func setupDeleteButton() {
        view.addSubview(deleteButton)
        deleteButton.addTarget(nil, action: #selector(showDeleteActivityAlert), for: .touchUpInside)
        deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupDeleteActivityAlert() {
        let confirmDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteActivityButtonTapped()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        deleteActivityAlert.addAction(confirmDeleteAction)
        deleteActivityAlert.addAction(cancel)
    }
    
    @objc private func showDeleteActivityAlert() {
        deleteActivityAlert.title = activityData.name.isEmpty ? activity.name : activityData.name
        self.present(deleteActivityAlert, animated: true)
        
    }
    
    private func deleteActivityButtonTapped() {
        delegate?.deleteActivity(activity)
        dismiss(animated: true)
    }

    private func setupToolBar() {
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
        
    }
    
    @objc private func saveButtonTapped() {
        delegate?.updateActivity(activity, with: activityData)
        dismiss(animated: true)
        
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
        dismiss(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCellReuseIdentifier", for: indexPath) as! TextViewTableViewCell
            
            cell.text = activity.name
            cell.delegate = self
            return cell
        case (0,1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTypePickerTableViewCellReuseIdentifier", for: indexPath) as! ActivityTypePickerTableViewCell
            cell.types = types
            cell.selectedTypeID = activity.typeID
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
            
        case (1,0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeStartTableViewCellReuseIdentifier", for: indexPath) as! TimeStartTableViewCell
            cell.time = activity.startDateTime
            cell.delegate = self
            return cell
            
        case (1,1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeFinishTableViewCellReuseIdentifier", for: indexPath) as! TimeFinishTableViewCell
            cell.time = activity.finishDateTime
            cell.minimumDate = activity.startDateTime
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCellReuseIdentifier", for: indexPath) as! TextViewTableViewCell
            
            cell.text = activity.name
            cell.delegate = self
            return cell
        }
        
    }

}

extension ActivityEditTableViewController: TextViewTableViewCellDelegate {
    func textViewDidChange(_ cell: TextViewTableViewCell) {
        if let _ = tableView.indexPath(for: cell) {
            activityData.name = cell.text
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

extension ActivityEditTableViewController: TimeStartTableViewCellDelegate {
    func startTimeChanged(to dateTime: Date) {
        if let finishTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? TimeFinishTableViewCell {
            finishTimeCell.minimumDate = dateTime
            activityData.startDateTime = dateTime
        }
    }
}

extension ActivityEditTableViewController: ActivityTypePickerTableViewCellDelegate {
    func selectedTypeChanged(to selectedTypeID: String) {
        if types.contains(where: {$0.id == selectedTypeID}) {
            activityData.typeID = selectedTypeID
        }
    }
}

extension ActivityEditTableViewController: TimeFinishTableViewCellDelegate {
    func finishTimeChanged(to dateTime: Date) {
        if activityData.startDateTime.isSameDay(with: dateTime) {
            activityData.finishDateTime = dateTime
        }
    }
    
    
}

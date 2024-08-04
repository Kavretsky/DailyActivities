//
//  HistoryTableViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 02.08.2024.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    private let historyVM: HistoryViewModel
    init(historyVM: HistoryViewModel) {
        self.historyVM = historyVM
        super.init(style: .insetGrouped)
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        setupToolBar()
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return historyVM.headers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return historyVM.dates[historyVM.headers[section], default: [] ].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return .init() }
        let key = historyVM.headers[indexPath.section]
        cell.date = historyVM.dates[key]?[indexPath.row]
        cell.accessoryType = .disclosureIndicator
         
        return cell
    }
    
    private func setupToolBar() {
        let closeButton = UIBarButtonItem(systemItem: .close)
        closeButton.target = self
        closeButton.action = #selector(self.closeButtonTapped)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = historyVM.headers[section]
        return historyVM.dates[key]?.first?.formatted(.dateTime.month(.wide).year())
    }
}

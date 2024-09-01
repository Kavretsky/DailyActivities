//
//  HistoryTableViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 02.08.2024.
//

import UIKit
import Combine
import Collections

class HistoryTableViewController: UITableViewController {
    
    private let historyVM: HistoryViewModel
    private var cancellables: Set<AnyCancellable> = []
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
        historyVM.$dates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return historyVM.headers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyVM.dates[historyVM.headers[section], default: [] ].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return .init() }
        let key = historyVM.headers[indexPath.section]
        let date = historyVM.dates[key]?[indexPath.row] ?? .now
        cell.setupCell(date: date, chartData: historyVM.chartDataDic[date] ?? [])
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
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
        return historyVM.dates[key]?.first?.formatted(.dateTime.year())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task {
            await historyVM.didSelectRowAt(indexPath)
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        Task {
            try await historyVM.loadData()
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        print("HistoryTableView deinit")
    }
}

#Preview {
    let historyService = ActivityRepositoryMock()
    let chartDataService = ChartDataServiceIml(typeRepository: ActivityTypeRepositoryMock())
    let historyVM = HistoryViewModel(historyService: historyService, chartDataService: chartDataService)
    return HistoryTableViewController(historyVM: historyVM)
}

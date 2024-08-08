//
//  TypeManagerTableViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 16.08.2023.
//

import UIKit
import Combine

final class TypeManagerTableViewController: UITableViewController {

    private let typeRepository: TypeManagerVM
    private var cancellables = Set<AnyCancellable>()
    
    init(typeRepository: TypeManagerVM) {
        self.typeRepository = typeRepository
        super.init(style: .insetGrouped)
        tableView.register(TypeManagerTableViewCell.self, forCellReuseIdentifier: "TypeManagerCellIdentifier")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "Type manager"
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .secondarySystemBackground
        setupToolBar()
        
        typeRepository.$types
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeRepository.types.filter { $0.isActive }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TypeManagerCellIdentifier", for: indexPath) as? TypeManagerTableViewCell else { return UITableViewCell() }

        let index = indexPath.row
        cell.type = typeRepository.types[index]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let selectedType = typeRepository.types[index]
        presentTypeEditorVC(with: selectedType)
    }
    
    private func presentTypeEditorVC(with type: ActivityType) {
        let typeEditVC = TypeEditorViewController(activityType: type)
        typeEditVC.delegate = self
        self.navigationController?.pushViewController(typeEditVC, animated: true)
    }
    
    private func setupToolBar() {
        let addTypeButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewType))
        navigationItem.rightBarButtonItem = addTypeButton
        
        let closeButton = UIBarButtonItem(systemItem: .close)
        closeButton.target = self
        closeButton.action = #selector(self.closeButtonTapped)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc private func addNewType() {
        Task {
            guard let newType = await typeRepository.addType(with: ActivityType.sampleData()) else { return }
            presentTypeEditorVC(with: newType)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

extension TypeManagerTableViewController: TypeEditorViewControllerDelegate {
    func deleteType(_ type: ActivityType) {
        Task {
            await typeRepository.removeType(type)
        }
    }
    
    func updateType(type: ActivityType, with data: ActivityType.Data) {
        Task {
            await typeRepository.updateType(type, with: data)
        }
    }
    
    var isTypeDeletable: Bool {
        typeRepository.types.count > 2
    }
    
}

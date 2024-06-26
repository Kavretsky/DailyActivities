//
//  TypeManagerTableViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 16.08.2023.
//

import UIKit

protocol TypeManagerTableViewControllerDelegate: AnyObject {
    func activityTypeChanged(_ typeID: ActivityType.ID)
}

final class TypeManagerTableViewController: UITableViewController {

    private let typeStore: TypeStore
    weak var delegate: TypeManagerTableViewControllerDelegate?
    
    init(typeStore: TypeStore) {
        self.typeStore = typeStore
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
//        tableView.rowHeight = UITableView.automaticDimension
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeStore.activeTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeManagerCellIdentifier", for: indexPath) as! TypeManagerTableViewCell

        let index = indexPath.row
        cell.type = typeStore.activeTypes[index]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let selectedType = typeStore.activeTypes[index]
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
        guard let newType = typeStore.addType(with: ActivityType.sampleData()) else { return }
        presentTypeEditorVC(with: newType)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension TypeManagerTableViewController: TypeEditorViewControllerDelegate {
    func deleteType(_ type: ActivityType) {
        typeStore.removeType(type)
        tableView.reloadData()
    }
    
    func updateType(type: ActivityType, with data: ActivityType.Data) {
        typeStore.updateType(type, with: data)
        tableView.reloadData()
        delegate?.activityTypeChanged(type.id)
    }
    
    var isTypeDeletable: Bool {
        typeStore.activeTypes.count > 2
    }
    
}




//
//  TypeManagerViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 16.08.2023.
//

import UIKit

final class TypeManagerTableViewController: UITableViewController {

    private let typeStore: TypeStore
    
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
        title = "Type manager"
        self.navigationItem.title = "Type manager"
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .secondarySystemBackground
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
//        cell.label.text = typeStore.activeTypes[index].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let activityType = typeStore.activeTypes[index]
        let typeEditVC = TypeEditorViewController(activityType: activityType)
        typeEditVC.delegate = self
        self.navigationController?.pushViewController(typeEditVC, animated: true)
    }

}

extension TypeManagerTableViewController: TypeEditorViewControllerDelegate {
    func deleteType(type: ActivityType) {
        typeStore.removeType(type)
        tableView.reloadData()
    }
    
    func updateType(type: ActivityType, with data: ActivityType.Data) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.typeStore.updateType(type, with: data)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    
}




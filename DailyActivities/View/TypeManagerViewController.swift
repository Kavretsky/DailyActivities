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
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 100
        // Do any additional setup after loading the view.
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
//        cell.label.text = typeStore.activeTypes[index].description
        return cell
    }
    

}




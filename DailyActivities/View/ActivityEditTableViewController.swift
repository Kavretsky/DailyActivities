//
//  ActivityEditTableViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 08.11.2023.
//

import UIKit

final class ActivityEditTableViewController: UITableViewController {
    private let types:[ActivityType]
    private let activity: Activity
    
    init(types: [ActivityType], activity: Activity) {
        self.types = types
        self.activity = activity
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
    }

    // MARK: - Table view data source

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
            cell.layoutIfNeeded()
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCellReuseIdentifier", for: indexPath) as! TextViewTableViewCell
            
            cell.text = activity.name
            cell.delegate = self
            return cell
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ActivityEditTableViewController: TVTableViewCellDelegate {
    func textViewDidChange(_ cell: TextViewTableViewCell) {
        if let _ = tableView.indexPath(for: cell) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

extension ActivityEditTableViewController: TimeStartTableViewCellDelegate {
    func startTimeChanged() {
        let startTimeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TimeStartTableViewCell
        let finishTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! TimeFinishTableViewCell
        print("startTimeCell")
        finishTimeCell.minimumDate = startTimeCell.time
    }
    
    
}

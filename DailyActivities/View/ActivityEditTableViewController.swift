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
        tableView.register(TVTableViewCell.self, forCellReuseIdentifier: "TVTableViewCellReuseIdentifier")
        self.navigationItem.title = "Activity"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TVTableViewCellReuseIdentifier", for: indexPath) as! TVTableViewCell
            
            cell.text = activity.name
            cell.delegate = self
            return cell
            
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TVTableViewCellReuseIdentifier", for: indexPath) as! TVTableViewCell
            
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
    func textViewDidChange(_ cell: TVTableViewCell) {
        if let _ = tableView.indexPath(for: cell) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
}

//
//  ActivityTableViewDiffableDataSource.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 21.12.2023.
//

import UIKit

class ActivityTableViewDiffableDataSource: UITableViewDiffableDataSource<MainViewController.Section, AnyHashable> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MainViewController.Section(rawValue: section)?.header
    }
}

//
//  TVTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 09.11.2023.
//

import UIKit

class TVTableViewCell: UITableViewCell {

    var text: String = ""
    
    private let textfield: UITextView = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.scrollEna
        return tf
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

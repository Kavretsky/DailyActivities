//
//  EmojiPickerTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 09.11.2023.
//

import UIKit

class EmojiPickerTableViewCell: UITableViewCell {

    var selectedEmojiID: Int = 0
    
    let emojiCollection: UICollectionView = {
        let emojiCollection = UICollectionView()
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        return emojiCollection
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        emojiCollection.dataSource = self
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

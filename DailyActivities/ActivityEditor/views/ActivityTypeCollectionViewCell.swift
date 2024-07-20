//
//  ActivityTypeCollectionViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 13.11.2023.
//

import UIKit

final class ActivityTypeCollectionViewCell: UICollectionViewCell {
    var emoji: String = ""
    {
        didSet {
            emojiLabel.text = emoji
        }
    }
    
    private let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 17)
        emojiLabel.textAlignment = .center
        return emojiLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        contentView.backgroundColor = .clear
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
    }
    
}

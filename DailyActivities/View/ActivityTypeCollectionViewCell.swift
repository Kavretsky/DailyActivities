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
        emojiLabel.font = .systemFont(ofSize: 22)
        emojiLabel.textAlignment = .center
        emojiLabel.numberOfLines = 1
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
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}

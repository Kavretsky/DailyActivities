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
            emojiLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 28),
            emojiLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let targetSize = CGSize(width: layoutAttributes.frame.width, height: layoutAttributes.frame.height)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(CGSize(width: 32, height: 28), withHorizontalFittingPriority: .dragThatCanResizeScene, verticalFittingPriority: .dragThatCanResizeScene)
        return layoutAttributes
    }
    
}

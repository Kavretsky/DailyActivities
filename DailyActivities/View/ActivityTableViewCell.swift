//
//  ActivityTableViewCell.swift
//  DailyActivities
//
//  Created by Anastasia Yunak on 27.09.2023.
//

import UIKit

final class ActivityTableViewCell: UITableViewCell {
    
    var activityDescription: String?
    {
        didSet {
            descriptionLabel.text = activityDescription
        }
    }
    
    var duration: String?
    {
        didSet {
            durationLabel.text = duration
        }
    }
    
    var typeEmoji: String?
    {
        didSet {
            typeLabel.text = typeEmoji
        }
    }
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let durationAndTypeSV = UIStackView()
        durationAndTypeSV.translatesAutoresizingMaskIntoConstraints = false
        durationAndTypeSV.axis = .horizontal
        durationAndTypeSV.distribution = .fill
        durationAndTypeSV.alignment = .fill
        durationAndTypeSV.addArrangedSubview(durationLabel)
        durationAndTypeSV.addArrangedSubview(typeLabel)
        
        let contentSV = UIStackView(arrangedSubviews: [descriptionLabel, durationAndTypeSV])
        contentSV.translatesAutoresizingMaskIntoConstraints = false
        contentSV.axis = .vertical
        contentSV.spacing = 5
        contentSV.alignment = .fill
        contentSV.distribution = .fill
        
        
        contentView.addSubview(contentSV)
        
        NSLayoutConstraint.activate([
            contentSV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentSV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentSV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentSV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            durationAndTypeSV.leadingAnchor.constraint(equalTo: contentSV.leadingAnchor),
            durationAndTypeSV.trailingAnchor.constraint(equalTo: contentSV.trailingAnchor),
            
//            typeLabel.topAnchor.constraint(equalTo: durationAndTypeSV.topAnchor, constant: 4),
//            typeLabel.bottomAnchor.constraint(equalTo: durationAndTypeSV.bottomAnchor, constant: -4),
//            typeLabel.trailingAnchor.constraint(equalTo: durationAndTypeSV.trailingAnchor, constant: -6),
            
        ])
    }
    
}

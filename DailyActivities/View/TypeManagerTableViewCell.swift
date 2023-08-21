//
//  TypeManagerTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 19.08.2023.
//

import UIKit

class TypeManagerTableViewCell: UITableViewCell {
    var type: ActivityType?
    {
        didSet {
            guard let type else { return }
            emojiBGView.backgroundColor = UIColor(rgbaColor: type.backgroundRGBA)
            emoji.text = type.emoji
            typeDescription.text = type.description
        }
    }
    
    let emojiBGView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 19
        return view
    }()
    
    let emoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22)
        return label
    }()
    
    let cellStack = UIStackView()
    
    let typeDescription: UILabel = {
        let typeDescription = UILabel()
        typeDescription.translatesAutoresizingMaskIntoConstraints = false
        typeDescription.font = .systemFont(ofSize: 17)
        typeDescription.numberOfLines = 0
        return typeDescription
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        emojiBGView.addSubview(emoji)
        
        cellStack.translatesAutoresizingMaskIntoConstraints = false
        cellStack.axis = .horizontal
        cellStack.spacing = 10
        cellStack.alignment = .center
        cellStack.addArrangedSubview(emojiBGView)
        cellStack.addArrangedSubview(typeDescription)
        
        contentView.addSubview(cellStack)
        NSLayoutConstraint.activate([
            emojiBGView.heightAnchor.constraint(equalToConstant: 38),
            emojiBGView.widthAnchor.constraint(equalToConstant: 41),
            
            emoji.centerXAnchor.constraint(equalTo: emojiBGView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiBGView.centerYAnchor),

            cellStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cellStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            cellStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cellStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

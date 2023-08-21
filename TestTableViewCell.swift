//
//  TestTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 20.08.2023.
//

import UIKit

class TestTableViewCell: UITableViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    let emojiBGView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 19
        view.backgroundColor = .green
        return view
    }()
    
    let stack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.addArrangedSubview(emojiBGView)
        stack.addArrangedSubview(label)
        contentView.addSubview(stack)
        layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiBGView.heightAnchor.constraint(equalToConstant: 38),
            emojiBGView.widthAnchor.constraint(equalToConstant: 44),
        ])
    }

}

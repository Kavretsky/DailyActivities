//
//  TimeStartTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 14.11.2023.
//

import UIKit

protocol TimeStartTableViewCellDelegate: AnyObject {
    func startTimeChanged()
}

final class TimeStartTableViewCell: UITableViewCell {
    var time: Date? {
        didSet {
            if timePicker.date != time, time != nil {
                timePicker.date = time!
            }
            delegate?.startTimeChanged()
        }
    }
    
    weak var delegate: TimeStartTableViewCellDelegate?
    
    private let timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.addTarget(nil, action: #selector(timePickerDidChanged), for: .valueChanged)
        return timePicker
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Started at"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func timePickerDidChanged() {
        time = timePicker.date
    }
    
    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [timeLabel, timePicker])
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintsConstants.leadingAnchorConstant),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: ConstraintsConstants.trailingAnchorConstant),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintsConstants.topAnchorConstant),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: ConstraintsConstants.bottomAnchorConstant),
            
            timeLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
        ])
        
        
    }
}

//
//  TimeFinishTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 14.11.2023.
//

import UIKit

protocol TimeFinishTableViewCellDelegate: AnyObject {
    func finishTimeChanged(to dateTime: Date)
}

class TimeFinishTableViewCell: UITableViewCell {

    var time: Date? {
        didSet {
            if timePicker.date != time, time != nil {
                timePicker.date = time!
                timeStack.isHidden = false
                finishButton.isHidden = true
                delegate?.finishTimeChanged(to: time!)
            }
        }
    }
    
    var minimumDate: Date!
    {
        didSet {
            timePicker.minimumDate = minimumDate
        }
    }
    
    weak var delegate: TimeFinishTableViewCellDelegate?
    
    private  let timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.addTarget(nil, action: #selector(timePickerDidChanged), for: .valueChanged)
        return timePicker
    }()
    
    private let finishButton: UIButton = {
        let finishButton = UIButton()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Finish now"
        configuration.contentInsets = .init(top: ConstraintsConstants.topAnchorConstant, leading: ConstraintsConstants.leadingAnchorConstant, bottom: ConstraintsConstants.topAnchorConstant, trailing: ConstraintsConstants.leadingAnchorConstant)
        
        let transformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = UIColor.systemBlue
            outgoing.font = UIFont.boldSystemFont(ofSize: 17)
            return outgoing
        }
        configuration.titleTextAttributesTransformer = transformer
        
        finishButton.configuration = configuration
        finishButton.addTarget(nil, action: #selector(finishButtonTapped), for: .touchUpInside)
        finishButton.contentHorizontalAlignment = .leading
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        
        return finishButton
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Finished at"
        return label
    }()
    
    private let timeStack: UIStackView = {
        let timeStack = UIStackView()
        timeStack.axis = .horizontal
        timeStack.spacing = 0
        timeStack.distribution = .fill
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.isHidden = true
        return timeStack
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
    
    
    @objc private func finishButtonTapped() {
        time = .now
        finishButton.isHidden = true
        timeStack.isHidden = false
    }
    
    private func setupViews() {
        timeStack.addArrangedSubview(timeLabel)
        timeStack.addArrangedSubview(timePicker)
        contentView.addSubview(timeStack)
        contentView.addSubview(finishButton)
        
        NSLayoutConstraint.activate([
            timeStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintsConstants.leadingAnchorConstant),
            timeStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: ConstraintsConstants.trailingAnchorConstant),
            timeStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintsConstants.topAnchorConstant),
            timeStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: ConstraintsConstants.bottomAnchorConstant),
            
            finishButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            finishButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            finishButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            finishButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        
        
    }
}

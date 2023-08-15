//
//  NewActivityVIew.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 12.08.2023.
//

import UIKit

final class NewActivityVIew: UIView {
    
    private var activityType = ActivityType.sample()

    private var typeChangeButton: UIButton = UIButton(type: .custom)
    private var descriptionTF: UITextField = UITextField()
    private var formHStack: UIStackView = UIStackView()
    private var newActivityButton = UIButton()
    private var newActivitySV = UIStackView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setupTypeButton()
        setupTextField()
        setupNewActivityButton()
        setupFormSV()
        setupNewActivitySV()
        self.backgroundColor = .tertiarySystemGroupedBackground
    }
    
    private func setupNewActivitySV() {
        newActivitySV.addArrangedSubview(formHStack)
        newActivitySV.addArrangedSubview(newActivityButton)
        self.addSubview(newActivitySV)
        
        newActivitySV.alignment = .center
        newActivitySV.spacing = 8
        newActivitySV.translatesAutoresizingMaskIntoConstraints = false
        
        let newActivitySVBottomConstraintToSafeArea = newActivitySV.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        newActivitySVBottomConstraintToSafeArea.priority = .defaultLow
        newActivitySVBottomConstraintToSafeArea.isActive = true
        NSLayoutConstraint.activate([
            newActivitySV.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            newActivitySV.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            newActivitySV.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor, constant: -8),
            newActivitySV.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            newActivitySV.heightAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    func setupNewActivityButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        newActivityButton.configuration = configuration
        
        let plusSymbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .heavy)
        let plusSymbolImage = UIImage(systemName: "plus", withConfiguration: plusSymbolConfig)?.withTintColor(UIColor.white)
        newActivityButton.setImage(plusSymbolImage, for: .normal)
        
        newActivityButton.layer.cornerRadius = 18
        newActivityButton.clipsToBounds = true
        newActivityButton.translatesAutoresizingMaskIntoConstraints = false
        newActivityButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        newActivityButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        newActivityButton.addTarget(self, action: #selector(newActivityButtonTapped), for: .touchUpInside)
    }
    
    @objc func newActivityButtonTapped() {
        print("newActivityButtonTapped tapped")
    }

    func setupTypeButton() {
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = activityType.color
        buttonConfiguration.title = activityType.emoji
        buttonConfiguration.cornerStyle = .capsule
        typeChangeButton.configuration = buttonConfiguration
        
        typeChangeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeChangeButton.heightAnchor.constraint(equalToConstant: 38),
            typeChangeButton.widthAnchor.constraint(equalToConstant: 42)
        ])
        
        typeChangeButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        typeChangeButton.titleLabel?.text = activityType.emoji
        typeChangeButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
    }
    
    
    
    @objc func buttonTapped() {
        print("button tapped")
    }
    
    func setupTextField() {
        descriptionTF.placeholder = activityType.description
        descriptionTF.clearButtonMode = .never
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func setupFormSV() {
        formHStack.translatesAutoresizingMaskIntoConstraints = false
        formHStack.addArrangedSubview(typeChangeButton)
        formHStack.addArrangedSubview(descriptionTF)
        formHStack.axis = .horizontal
        formHStack.alignment = .center
        formHStack.backgroundColor = .white
        formHStack.spacing = 6
        formHStack.layer.cornerRadius = 19
    }


}

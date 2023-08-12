//
//  NewActivityVIew.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 12.08.2023.
//

import UIKit

class NewActivityVIew: UIView {
    
    private var activityType = ActivityType.sample()

    private var typeChangeButton: UIButton = UIButton(type: .custom)
    private var descriptionTF: UITextField = UITextField()
    private var controlsHStack: UIStackView = UIStackView()
    private var newActivityButton = UIButton()
    private var newActivitySV = UIStackView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setupTypeButton()
        setupTextField()
        setupNewActivityButton()
        setupControlHStack()
        setupNewActivitySV()
        self.backgroundColor = .tertiarySystemGroupedBackground
    }
    
    private func setupNewActivitySV() {
        newActivitySV.addArrangedSubview(controlsHStack)
        newActivitySV.addArrangedSubview(newActivityButton)
        self.addSubview(newActivitySV)
        newActivitySV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newActivitySV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            newActivitySV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            newActivitySV.bottomAnchor.constraint(equalTo: bottomAnchor),
            newActivitySV.topAnchor.constraint(equalTo: topAnchor)
        ])
        newActivitySV.backgroundColor = .tertiarySystemGroupedBackground
        newActivitySV.spacing = 12
//        NSLayoutConstraint.activate([
//            controlsHStack.leadingAnchor.constraint(equalTo: newActivitySV.leadingAnchor, constant: 15),
//            newActivityButton.trailingAnchor.constraint(equalTo: newActivitySV.trailingAnchor, constant: 15)
//        ])
        
    }
    
    func setupNewActivityButton() {
        newActivityButton.backgroundColor = UIColor.systemBlue
        let plusSymbolConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let plusSymbolImage = UIImage(systemName: "plus", withConfiguration: plusSymbolConfig)?.withTintColor(UIColor.white)
        newActivityButton.setImage(plusSymbolImage, for: .normal)
        newActivityButton.layer.cornerRadius = newActivityButton.frame.size.width / 2
        newActivityButton.translatesAutoresizingMaskIntoConstraints = false
        newActivityButton.clipsToBounds = true
        newActivityButton.addTarget(self, action: #selector(newActivityButtonTapped), for: .touchUpInside)
        newActivityButton.tintColor = .white
        newActivityButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
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
            typeChangeButton.widthAnchor.constraint(equalToConstant: 45)
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
    
    func setupControlHStack() {
//        view.addSubview(controlsHStack)
        controlsHStack.translatesAutoresizingMaskIntoConstraints = false
        controlsHStack.addArrangedSubview(typeChangeButton)
        controlsHStack.addArrangedSubview(descriptionTF)
        controlsHStack.axis = .horizontal
//        controlsHStack.distribution = .fill
        controlsHStack.alignment = .center
        controlsHStack.backgroundColor = .white
        
//        controlsHStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
//        controlsHStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 15).isActive = true
//        controlsHStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        controlsHStack.heightAnchor.constraint(equalToConstant: 38).isActive = true
        controlsHStack.spacing = 6
        let maskView = UIView()
        maskView.backgroundColor = .black
        maskView.layer.cornerRadius = min(controlsHStack.bounds.width, controlsHStack.bounds.height) / 2
        controlsHStack.layer.cornerRadius = controlsHStack.bounds.height / 2
        
    }


}

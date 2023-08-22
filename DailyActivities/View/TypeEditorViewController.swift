//
//  TypeEditorViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 21.08.2023.
//

import UIKit

class TypeEditorViewController: UIViewController {
    
    let activityType: ActivityType
    
    let emojiTF: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 28
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 22)
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 64).isActive = true
        return textField
    }()
    
    let descriptionTF: UITextField = {
        let descriptionTF = UITextField()
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        descriptionTF.layer.cornerRadius = 10
        descriptionTF.placeholder = NSLocalizedString("Type description", comment: "Type description")
        descriptionTF.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        
        descriptionTF.backgroundColor = .white
        descriptionTF.textAlignment = .center
        descriptionTF.font = .boldSystemFont(ofSize: 22)
        return descriptionTF
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 30
        stack.alignment = .center
        return stack
    }()
    
    
    let colorPickerSection: ColorPickerSection = {
        let colorPickerSection = ColorPickerSection(color: .black)
        colorPickerSection.translatesAutoresizingMaskIntoConstraints = false
        colorPickerSection.backgroundColor = .white
        return colorPickerSection
    }()
    
    private let colorPicker = UIColorPickerViewController()
    
    init(activityType: ActivityType) {
        self.activityType = activityType
        super.init(nibName: nil, bundle: nil)
        self.emojiTF.text = activityType.emoji
        self.descriptionTF.text = activityType.description
        self.colorPickerSection.color = UIColor(rgbaColor: activityType.backgroundRGBA)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        colorPicker.delegate = self
        colorPicker.supportsAlpha = false
        colorPicker.selectedColor = UIColor(rgbaColor: activityType.backgroundRGBA)
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentColorPicker))
        colorPickerSection.addGestureRecognizer(tap)
        setupUI()
    }
    

    private func setupUI() {
        setupEmojiTF()
        setupDescriptionTF()
        
        stack.addArrangedSubview(emojiTF)
        stack.addArrangedSubview(descriptionTF)
        stack.addArrangedSubview(colorPickerSection)
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionTF.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            descriptionTF.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            colorPickerSection.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            colorPickerSection.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            colorPickerSection.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    private func setupEmojiTF() {
        emojiTF.backgroundColor = UIColor(rgbaColor: activityType.backgroundRGBA)
        
    }
    
    private func setupDescriptionTF() {
        descriptionTF.backgroundColor = .white
    }

    @objc private func presentColorPicker() {
        self.present(colorPicker, animated: true)
    }
}

extension TypeEditorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        colorPickerSection.color = color
        emojiTF.backgroundColor = colorPickerSection.color
    }
    
}

//
//  TypeEditorViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 21.08.2023.
//

import UIKit

protocol TypeEditorViewControllerDelegate: AnyObject {
    func deleteType(type: ActivityType)
    func updateType(type: ActivityType, with data: ActivityType.Data)
}

//class EmojiTextField: UITextField {
//    override var textInputMode: UITextInputMode? {
//        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
//    }
//}

class TypeEditorViewController: UIViewController {
    
    let typeToEdit: ActivityType
    
    private var typeData: ActivityType.Data
    {
        didSet{
            delegate?.updateType(type: typeToEdit, with: typeData)
            emojiTF.text = typeData.emoji
        }
    }
    
    weak var delegate: TypeEditorViewControllerDelegate?
    
    let emojiTF: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 28
        textField.clipsToBounds = true
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
        descriptionTF.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let colorPicker = UIColorPickerViewController()
    
    init(activityType: ActivityType) {
        self.typeToEdit = activityType
        self.typeData = activityType.data
        super.init(nibName: nil, bundle: nil)
        self.emojiTF.text = activityType.emoji
        self.descriptionTF.text = activityType.description
        self.colorPickerSection.color = UIColor(rgbaColor: activityType.backgroundRGBA)
        self.colorPickerSection.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.delegate = self
        colorPicker.supportsAlpha = false
        colorPicker.selectedColor = UIColor(rgbaColor: typeToEdit.backgroundRGBA)
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentColorPicker))
        colorPickerSection.addGestureRecognizer(tap)
        
        descriptionTF.delegate = self
        emojiTF.delegate = self
        
        setupUI()
    }
    

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        setupEmojiTF()
        setupDescriptionTF()
        
        stack.addArrangedSubview(emojiTF)
        stack.addArrangedSubview(descriptionTF)
        stack.addArrangedSubview(colorPickerSection)
        scrollView.addSubview(stack)
        view.addSubview(scrollView)
        
        setupConstraints()
        
       
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30),
            
            descriptionTF.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            descriptionTF.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            colorPickerSection.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            colorPickerSection.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            colorPickerSection.heightAnchor.constraint(equalToConstant: 56),
            
            
//            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
//            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
//            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            descriptionTF.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
//            descriptionTF.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
//            colorPickerSection.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
//            colorPickerSection.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
//            colorPickerSection.heightAnchor.constraint(equalToConstant: 56),
//            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
    
    private func setupEmojiTF() {
        emojiTF.backgroundColor = UIColor(rgbaColor: typeToEdit.backgroundRGBA)
        
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

extension TypeEditorViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == descriptionTF {
            typeData.description = textField.text ?? "Type Description"
        }
        if textField == emojiTF {
            typeData.emoji = textField.text ?? ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == emojiTF else { return true }
        guard !string.isEmpty else { return false }
        typeData.emoji = string
        textField.text = ""
        return true
    }
}

extension TypeEditorViewController: ColorPickerSectionDelegate {
    func updateColor(color: UIColor) {
        typeData.backgroundRGBA = RGBAColor(color: color)
    }
    
    
}

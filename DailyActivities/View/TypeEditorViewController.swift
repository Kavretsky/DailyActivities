//
//  TypeEditorViewController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 21.08.2023.
//

import UIKit

protocol TypeEditorViewControllerDelegate: AnyObject {
    func deleteType(_ type: ActivityType)
    func updateType(type: ActivityType, with data: ActivityType.Data)
    var isTypeDeletable: Bool { get }
}

//class EmojiTextField: UITextField {
//    override var textInputMode: UITextInputMode? {
//        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
//    }
//}

final class TypeEditorViewController: UIViewController {
    
    let typeToEdit: ActivityType
    
    private var typeData: ActivityType.Data
    {
        didSet{
            delegate?.updateType(type: typeToEdit, with: typeData)
            emojiTF.text = typeData.emoji
            descriptionTF.text = typeData.description
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
        stack.distribution = .fillEqually
        return stack
    }()
    
    
    let colorPickerSection: ColorPickerSection = {
        let colorPickerSection = ColorPickerSection(color: .black)
        colorPickerSection.translatesAutoresizingMaskIntoConstraints = false
        colorPickerSection.backgroundColor = .white
        return colorPickerSection
    }()
    
    let deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIButton.Configuration.plain()
        
        deleteButton.configuration = configuration
        deleteButton.tintColor = .red
//        deleteButton.backgroundColor = .clear
        deleteButton.setTitle("Delete type", for: .normal)
        
        return deleteButton
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .always
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
    
    private let deleteTypeAlert: UIAlertController = {
        let sheetAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        return sheetAlert
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.delegate = self
        colorPicker.supportsAlpha = false
        colorPicker.selectedColor = UIColor(rgbaColor: typeToEdit.backgroundRGBA)
        let presentCPTap = UITapGestureRecognizer(target: self, action: #selector(presentColorPicker))
        colorPickerSection.addGestureRecognizer(presentCPTap)
        
        descriptionTF.delegate = self
        emojiTF.delegate = self
        
        setupUI()
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    
    @objc private func dismissKeyboard() {
            view.endEditing(true)
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
        if delegate?.isTypeDeletable ?? false {
            view.addSubview(deleteButton)
            setupDeleteButton()
            setupDeleteTypeAlert()
        }
        setupConstraints()
    }
    
    
    
    private func setupDeleteButton() {
        deleteButton.addTarget(nil, action: #selector(showDeleteTypeAlert), for: .touchUpInside)
        deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
    }
    
    private func setupDeleteTypeAlert() {
        let confirmDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteType()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        deleteTypeAlert.addAction(confirmDeleteAction)
        deleteTypeAlert.addAction(cancel)
    }
    
    @objc private func showDeleteTypeAlert() {
        deleteTypeAlert.title = descriptionTF.text
        self.present(deleteTypeAlert, animated: true)
        
    }
    
    private func deleteType() {
        delegate?.deleteType(typeToEdit)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -15),
            
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
//            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30),
            
            descriptionTF.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            descriptionTF.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            colorPickerSection.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            colorPickerSection.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            colorPickerSection.heightAnchor.constraint(equalToConstant: 56),
            
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
//        guard !string.isEmpty else { return false }
        typeData.emoji = string
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension TypeEditorViewController: ColorPickerSectionDelegate {
    func updateColor(color: UIColor) {
        typeData.backgroundRGBA = RGBAColor(color: color)
    }
    
    
}

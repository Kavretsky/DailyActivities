//
//  NewActivityVIew.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 12.08.2023.
//

import UIKit

final class NewActivityVIew: UIView {
    
    private let typeStore = TypeStore()
    private var chosenIndex = 0
    private var chosenType: ActivityType {
        typeStore.activeTypes[chosenIndex]
    }

    private var typeButton: UIButton = UIButton(type: .custom)
    private var typeButtonBackground = UIView()
    private var descriptionTF: UITextField = UITextField()
    private var formSV: UIStackView = UIStackView()
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
    
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setupDivider()
        setupTypeButton()
        setupTextField()
        setupNewActivityButton()
        setupFormSV()
        setupNewActivitySV()
        self.backgroundColor = .tertiarySystemGroupedBackground
    }
    
    private func setupNewActivitySV() {
        newActivitySV.addArrangedSubview(formSV)
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
    
    private func setupNewActivityButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        newActivityButton.configuration = configuration
        
        let plusSymbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .heavy)
        let plusSymbolImage = UIImage(systemName: "plus", withConfiguration: plusSymbolConfig)?.withTintColor(UIColor.white)
        newActivityButton.setImage(plusSymbolImage, for: .normal)
        
        newActivityButton.layer.cornerRadius = 18
        newActivityButton.clipsToBounds = true
        newActivityButton.translatesAutoresizingMaskIntoConstraints = false
        newActivityButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        newActivityButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        newActivityButton.addTarget(self, action: #selector(newActivityButtonTapped), for: .touchUpInside)
    }
    
    @objc private func newActivityButtonTapped() {
        print("newActivityButtonTapped tapped")
    }

    private func setupTypeButton() {
        typeButtonBackground.addSubview(typeButton)
        typeButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        typeButtonBackground.backgroundColor = UIColor(rgbaColor: chosenType.backgroundRGBA)
        typeButtonBackground.layer.cornerRadius = 19
        typeButtonBackground.clipsToBounds = true
        typeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeButtonBackground.heightAnchor.constraint(equalToConstant: 38),
            typeButtonBackground.widthAnchor.constraint(equalToConstant: 45),
            typeButton.leadingAnchor.constraint(equalTo: typeButtonBackground.leadingAnchor),
            typeButton.trailingAnchor.constraint(equalTo: typeButtonBackground.trailingAnchor),
            typeButton.topAnchor.constraint(equalTo: typeButtonBackground.topAnchor),
            typeButton.bottomAnchor.constraint(equalTo: typeButtonBackground.bottomAnchor),
        ])
        
        typeButton.setTitle(chosenType.emoji, for: .normal)
        typeButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        
        typeButton.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        typeButtonBackground.addInteraction(interaction)
    }
    
    
    @objc private func typeButtonTapped() {
        chosenIndex = (chosenIndex + 1) % typeStore.activeTypes.count
        animateTypeChange()
    }
    
    private func animateTypeChange() {
        let rollAnimation = CATransition()
        rollAnimation.type = .push
        rollAnimation.subtype = .fromTop
        rollAnimation.duration = 0.3
        
        typeButton.layer.add(rollAnimation, forKey: nil)
        if !descriptionTF.hasText {
            descriptionTF.layer.add(rollAnimation, forKey: nil)
        }
        typeButton.setTitle(chosenType.emoji, for: .normal)
        descriptionTF.placeholder = chosenType.description
        
        UIView.animate(withDuration: 0.3) {
            self.typeButtonBackground.backgroundColor = UIColor(rgbaColor: self.chosenType.backgroundRGBA)
        }
    }
    
    private func setupTextField() {
        descriptionTF.placeholder = chosenType.description
        descriptionTF.clearButtonMode = .never
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        descriptionTF.adjustsFontSizeToFitWidth = true
        
    }
    
    private func setupFormSV() {
        formSV.translatesAutoresizingMaskIntoConstraints = false
        formSV.addArrangedSubview(typeButtonBackground)
        
        let descriptionTFBackground = UIView()
        descriptionTFBackground.translatesAutoresizingMaskIntoConstraints = false
        descriptionTFBackground.addSubview(descriptionTF)
        descriptionTFBackground.clipsToBounds = true
        formSV.addArrangedSubview(descriptionTFBackground)
        NSLayoutConstraint.activate([
            descriptionTF.leadingAnchor.constraint(equalTo: descriptionTFBackground.leadingAnchor),
            descriptionTF.trailingAnchor.constraint(equalTo: descriptionTFBackground.trailingAnchor, constant: -6),
            descriptionTF.topAnchor.constraint(equalTo: descriptionTFBackground.topAnchor),
            descriptionTF.bottomAnchor.constraint(equalTo: descriptionTFBackground.bottomAnchor),
            descriptionTFBackground.topAnchor.constraint(equalTo: formSV.topAnchor),
            descriptionTFBackground.bottomAnchor.constraint(equalTo: formSV.bottomAnchor),
        ])
        
        
        formSV.axis = .horizontal
        formSV.alignment = .center
        formSV.backgroundColor = .white
        formSV.spacing = 6
        formSV.layer.cornerRadius = 19
    }
    
    private func setupDivider() {
        let divider = UIView()
        divider.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 233/255, alpha: 1.0)
        self.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }


}

extension NewActivityVIew: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider:
                {  _ in
                    
                    let managerAction = UIAction(
                        title: NSLocalizedString("Type Manager", comment: ""),
                        image: UIImage(systemName: "slider.vertical.3")
                    ) { action in
                        print("open type manager")
                    }
                    
                    var typeSelectionActions = [UIAction]()
                    self.typeStore.activeTypes.forEach { [weak self] type in
                        guard let self else { return }
                        let action = UIAction(title: type.emoji + " " + type.description,
                                              image: type == self.chosenType ? UIImage(systemName: "checkmark") : nil
                        ) { [weak self]  _ in
                            guard let self else { return }
                            self.chosenIndex = self.typeStore.activeTypes.firstIndex(of: type) ?? 0
                            self.animateTypeChange()
                        }
                        typeSelectionActions.append(action)
                    }
                    
                    let goToMenu = UIMenu(title: "Go to", children: typeSelectionActions)
                    
                    
                    
                    
                    return UIMenu(title: "", children: [managerAction, goToMenu])
                })
    }
    
    
}

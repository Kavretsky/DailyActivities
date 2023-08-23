//
//  NewActivityVIew.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 12.08.2023.
//

import UIKit
import Combine

protocol NewActivityViewDelegate: AnyObject {
    func showTypeManager()
}

final class NewActivityView: UIView {
    
    private let typeStore: TypeStore
    private var chosenIndex = 0
    private var chosenType: ActivityType {
        typeStore.activeTypes[chosenIndex]
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: NewActivityViewDelegate?

    private var typeButton: UIButton = {
        let typeButton = UIButton(type: .custom)
        typeButton.translatesAutoresizingMaskIntoConstraints = false
        typeButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        
        return typeButton
    }()
    
    private var typeButtonBackground = {
        let typeButtonBackground = UIView()
        typeButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        typeButtonBackground.layer.cornerRadius = 19
        typeButtonBackground.clipsToBounds = true
        
        return typeButtonBackground
    }()
    
    private var descriptionTF: UITextField = {
        let descriptionTF = UITextField()
        descriptionTF.clearButtonMode = .never
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        descriptionTF.adjustsFontSizeToFitWidth = true
        
        return descriptionTF
    }()
    
    private var formSV: UIStackView = {
        let formSV = UIStackView()
        formSV.translatesAutoresizingMaskIntoConstraints = false
        formSV.axis = .horizontal
        formSV.alignment = .center
        formSV.backgroundColor = .white
        formSV.spacing = 6
        formSV.layer.cornerRadius = 19
        
        return formSV
    }()
    
    
    private var newActivityButton = {
        let newActivityButton = UIButton()
        
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
        
        return newActivityButton
    }()
    private var newActivitySV = UIStackView()
    
    init(typeStore: TypeStore) {
        self.typeStore = typeStore
        super.init(frame: .null)
        setupUI()
        
        typeStore.typesPublisher
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sink { [weak self] bool in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.descriptionTF.placeholder = self.chosenType.description
                    self.typeButton.setTitle(self.chosenType.emoji, for: .normal)
                    self.typeButtonBackground.backgroundColor = UIColor(rgbaColor: self.chosenType.backgroundRGBA)
                }
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        newActivityButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        newActivityButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        newActivityButton.addTarget(self, action: #selector(newActivityButtonTapped), for: .touchUpInside)
    }
    
    @objc private func newActivityButtonTapped() {
        print("newActivityButtonTapped tapped")
    }

    private func setupTypeButton() {
        typeButtonBackground.addSubview(typeButton)
        typeButtonBackground.backgroundColor = UIColor(rgbaColor: chosenType.backgroundRGBA)
        
        NSLayoutConstraint.activate([
            typeButtonBackground.heightAnchor.constraint(equalToConstant: 38),
            typeButtonBackground.widthAnchor.constraint(equalToConstant: 45),
            typeButton.leadingAnchor.constraint(equalTo: typeButtonBackground.leadingAnchor),
            typeButton.trailingAnchor.constraint(equalTo: typeButtonBackground.trailingAnchor),
            typeButton.topAnchor.constraint(equalTo: typeButtonBackground.topAnchor),
            typeButton.bottomAnchor.constraint(equalTo: typeButtonBackground.bottomAnchor),
        ])
        
        typeButton.setTitle(chosenType.emoji, for: .normal)
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
        rollAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
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
    }
    
    private func setupFormSV() {
        
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

    deinit {
        cancellables.forEach { $0.cancel() }
    }

}

extension NewActivityView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider:
                { [weak self] _ in
                    
                    let managerAction = UIAction(
                        title: NSLocalizedString("Type Manager", comment: ""),
                        image: UIImage(systemName: "slider.vertical.3")
                    ) { [weak self] action in
                        self?.delegate?.showTypeManager()
                    }
                    
                    var typeSelectionActions = [UIAction]()
                    self?.typeStore.activeTypes.forEach { [weak self] type in
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

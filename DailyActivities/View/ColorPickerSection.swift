//
//  TypeColorPickerView.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 21.08.2023.
//

import UIKit

protocol ColorPickerSectionDelegate: AnyObject {
    func updateColor(color: UIColor)
}

final class ColorPickerSection: UIView {
    
    weak var delegate: ColorPickerSectionDelegate?
    
    var color: UIColor
    {
        willSet {
            colorCircle.backgroundColor = newValue
            delegate?.updateColor(color: newValue)
        }
    }
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        
        let label = UILabel()
        label.text = NSLocalizedString("Color", comment: "Type color pick section on TypeEdit screen")
        label.font = .boldSystemFont(ofSize: 17)
        stack.addArrangedSubview(label)
        return stack
    }()
    
    private let gradientCircle: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 16
        backgroundView.clipsToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = .init(origin: .zero, size: .init(width: 32, height: 32))
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        let gradientColors = [
            UIColor(red: 0.83, green: 0.33, blue: 0.34, alpha: 1),
            UIColor(red: 0.41, green: 0.27, blue: 0.87, alpha: 1),
            UIColor(red: 0.49, green: 0.89, blue: 0.56, alpha: 1),
            UIColor(red: 0.88, green: 0.89, blue: 0.39, alpha: 1),
            UIColor(red: 0.83, green: 0.33, blue: 0.34, alpha: 1)
            ]
        
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        
        
        backgroundView.layer.addSublayer(gradientLayer)
    
        NSLayoutConstraint.activate([
            backgroundView.heightAnchor.constraint(equalToConstant: 32),
            backgroundView.widthAnchor.constraint(equalToConstant: 32),
        ])
        
        return backgroundView
    }()
    
    private let whiteCircle: UIView = {
        let whiteCircle = UIView()
        whiteCircle.layer.cornerRadius = 13
        whiteCircle.backgroundColor = .white
        whiteCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteCircle.heightAnchor.constraint(equalToConstant: 26),
            whiteCircle.widthAnchor.constraint(equalToConstant: 26),
        ])
        return whiteCircle
    }()
    
    private let colorCircle: UIView = {
        let colorCircle = UIView()
        colorCircle.translatesAutoresizingMaskIntoConstraints = false
        colorCircle.layer.cornerRadius = 11.5
        NSLayoutConstraint.activate([
            colorCircle.heightAnchor.constraint(equalToConstant: 21),
            colorCircle.widthAnchor.constraint(equalToConstant: 21),
        ])
        return colorCircle
    }()
    
    init(color: UIColor) {
        self.color = color
        colorCircle.backgroundColor = color
        super.init(frame: .null)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 10
        gradientCircle.addSubview(whiteCircle)
        gradientCircle.addSubview(colorCircle)
        stack.addArrangedSubview(gradientCircle)
        
        self.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientCircle.heightAnchor.constraint(equalToConstant: 32),
            gradientCircle.widthAnchor.constraint(equalToConstant: 32),
            whiteCircle.centerXAnchor.constraint(equalTo: gradientCircle.centerXAnchor),
            whiteCircle.centerYAnchor.constraint(equalTo: gradientCircle.centerYAnchor),
            colorCircle.centerXAnchor.constraint(equalTo: gradientCircle.centerXAnchor),
            colorCircle.centerYAnchor.constraint(equalTo: gradientCircle.centerYAnchor),
        ])
    }

}

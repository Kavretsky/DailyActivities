//
//  TypeColorPickerView.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 21.08.2023.
//

import UIKit

class ColorPickerSection: UIView {
    
    private var color: UIColor
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        
        let label = UILabel()
        label.text = NSLocalizedString("Color", comment: "Type color pick section on TypeEdit screen")
        label.font = .systemFont(ofSize: 17)
        stack.addArrangedSubview(label)
        return stack
    }()
    
    private let colorPicker: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 16
//        backgroundView.backgroundColor = UIColor.clear
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        let lit = #colorLiteral(red: 0.3254901961, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        
        let gradientColors = [
            UIColor(red: 0.83, green: 0.33, blue: 0.34, alpha: 1),
            UIColor(red: 0.41, green: 0.27, blue: 0.87, alpha: 1),
            UIColor(red: 0.49, green: 0.89, blue: 0.56, alpha: 1),
            UIColor(red: 0.88, green: 0.89, blue: 0.39, alpha: 1),
            UIColor(red: 0.83, green: 0.33, blue: 0.34, alpha: 1)
            ]
        
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        backgroundView.layer.addSublayer(gradientLayer)
        
//        gradientLayer.frame = backgroundView.bounds
        
        return backgroundView
    }()
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .null)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 10
        stack.addArrangedSubview(colorPicker)
        
        self.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorPicker.heightAnchor.constraint(equalToConstant: 32),
            colorPicker.widthAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

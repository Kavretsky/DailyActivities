//
//  TextViewTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 09.11.2023.
//

import UIKit

protocol TextViewTableViewCellDelegate: AnyObject {
    func textViewDidChange(_ cell: TextViewTableViewCell)
}

final class TextViewTableViewCell: UITableViewCell {
    var text: String = ""
    {
        willSet {
            if textView.text != newValue {
                textView.text = newValue
            }
        }
    }
    
    weak var delegate: TextViewTableViewCellDelegate?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.sizeToFit()
        textView.font = .systemFont(ofSize: 17)
        return textView
    }()
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        textView.delegate = self
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
        delegate?.textViewDidChange(self)
    }
}

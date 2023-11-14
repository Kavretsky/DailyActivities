//
//  ActivityTypePickerTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 09.11.2023.
//

import UIKit

final class ActivityTypePickerTableViewCell: UITableViewCell {

    var selectedTypeID: String = ""
    
    var types: [ActivityType] = []
    
    private let activityTypeCollection: SelfSizingCollectionView!
    private let activityTypeCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        return layout
    }()
    
    private let selectedTypeBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 17
        view.frame.size = .init(width: 34, height: 30)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        activityTypeCollection = SelfSizingCollectionView(frame: .zero, collectionViewLayout: activityTypeCollectionViewFlowLayout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activityTypeCollection.backgroundColor = .clear
        activityTypeCollection.dataSource = self
        activityTypeCollection.delegate = self
        activityTypeCollection.register(ActivityTypeCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityTypeCollectionViewCellIdentifier")
        activityTypeCollection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectedTypeBackground)
        contentView.addSubview(activityTypeCollection)
        NSLayoutConstraint.activate([
            activityTypeCollection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintsConstants.topAnchorConstant),
            activityTypeCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: ConstraintsConstants.bottomAnchorConstant),
            activityTypeCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintsConstants.leadingAnchorConstant),
            activityTypeCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: ConstraintsConstants.trailingAnchorConstant),
        ])
        
    }
    
    private func moveBackgroundTo(_ cell: UICollectionViewCell) {
        
        UIView.animate(withDuration: 0.2) {
            self.selectedTypeBackground.center = CGPoint(x: cell.center.x + ConstraintsConstants.leadingAnchorConstant, y: cell.center.y + ConstraintsConstants.topAnchorConstant)
            if let selectedType = self.types.first(where: {$0.id == self.selectedTypeID}) {
                self.selectedTypeBackground.backgroundColor = UIColor(rgbaColor: selectedType.backgroundRGBA)
            }
        }
        print(cell.center)
        print(selectedTypeBackground.center)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ActivityTypePickerTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityTypeCollectionViewCellIdentifier", for: indexPath) as! ActivityTypeCollectionViewCell
        let type = types[indexPath.row]
        cell.emoji = type.emoji
        if type.id == selectedTypeID {
            selectedTypeBackground.center = CGPoint(x: cell.center.x + ConstraintsConstants.leadingAnchorConstant / 2, y: cell.center.y + ConstraintsConstants.topAnchorConstant / 2)
            selectedTypeBackground.backgroundColor = UIColor(rgbaColor: type.backgroundRGBA)
        }
//        cell.backgroundColor = .red
        return cell
    }
}

extension ActivityTypePickerTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTypeID = types[indexPath.row].id
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            moveBackgroundTo(selectedCell)
        }
    }
}

fileprivate struct ConstraintsConstants {
    static let leadingAnchorConstant: CGFloat = 20
    static let trailingAnchorConstant: CGFloat = -20
    static let topAnchorConstant: CGFloat = 10
    static let bottomAnchorConstant: CGFloat = -10
}

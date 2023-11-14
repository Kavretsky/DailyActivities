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
            activityTypeCollection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            activityTypeCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            activityTypeCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityTypeCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
    }
    
    private func moveBackgroundToSelectedTypeCell(_ cell: UICollectionViewCell) {
        
        UIView.animate(withDuration: 0.2) {
            self.selectedTypeBackground.frame.origin = CGPoint(x: cell.frame.midX, y: cell.frame.midY)
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
        cell.emoji = types[indexPath.row].emoji
//        cell.backgroundColor = .red
        return cell
    }
}

extension ActivityTypePickerTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTypeID = types[indexPath.row].id
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            moveBackgroundToSelectedTypeCell(selectedCell)
        }
    }
}

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
    
    private let activityTypeCollection: UICollectionView = {
        let typeCollection = UICollectionView()
        typeCollection.translatesAutoresizingMaskIntoConstraints = false
        return typeCollection
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activityTypeCollection.dataSource = self
        activityTypeCollection.register(ActivityTypeCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityTypeCollectionViewCellIdentifier")
        activityTypeCollection.collectionViewLayout = setupFlowLayout()
//        emojiCollection.delegate = self
        
    }
    
    private func setupFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        return layout
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
        return cell
    }
}



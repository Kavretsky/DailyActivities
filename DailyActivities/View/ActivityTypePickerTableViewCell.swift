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
    
    let activityTypeCollection: UICollectionView!
    let activityTypeCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 320, height: 28)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
//        layout.scrollDirection = .vertical
        return layout
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        activityTypeCollection = UICollectionView(frame: .zero, collectionViewLayout: activityTypeCollectionViewFlowLayout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activityTypeCollection.dataSource = self
        activityTypeCollection.delegate = self
        activityTypeCollection.register(ActivityTypeCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityTypeCollectionViewCellIdentifier")
        activityTypeCollection.translatesAutoresizingMaskIntoConstraints = false
//        activityTypeCollection.sizeToFit()
        
        contentView.addSubview(activityTypeCollection)
        NSLayoutConstraint.activate([
//            activityTypeCollection.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            activityTypeCollection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            activityTypeCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            activityTypeCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityTypeCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: activityTypeCollection.collectionViewLayout.collectionViewContentSize.height)
        ])
        
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
        cell.backgroundColor = .red
        print(cell.contentView.frame.size)
        print(collectionView.contentSize)
        return cell
    }
}

extension ActivityTypePickerTableViewCell: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        CGSize(width: 32, height: 28)
//    }
    
  
}


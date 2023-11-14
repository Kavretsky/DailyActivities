//
//  SelfSizingCollectionView.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 14.11.2023.
//

import UIKit

class SelfSizingCollectionView: UICollectionView {

    override var contentSize: CGSize 
    {
        didSet {
            if oldValue.height != self.contentSize.height {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override var intrinsicContentSize: CGSize
    {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: contentSize.height)
    }

}

//
//  LINBadgeFlowLayout.swift
//  Lingua
//
//  Created by Hoang Ta on 7/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINBadgeFlowLayout: UICollectionViewFlowLayout {
   
    override func prepareLayout() {
        super.prepareLayout()
        let totalItemWidth = CGRectGetWidth(collectionView.frame) * 0.9
        itemSize = CGSizeMake(totalItemWidth/5, totalItemWidth/5*1.1) //There should be 5 items per line and the item height is calculated be the width timed by 1.1
        minimumInteritemSpacing = 1
        headerReferenceSize = CGSizeMake(collectionView.bounds.width, 30)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]! {
        let array = super.layoutAttributesForElementsInRect(rect)
        
        for attributes in array {
            println(attributes.frame)
        }
        
        return array
    }
}

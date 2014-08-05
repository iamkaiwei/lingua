//
//  LINBadgeCell.swift
//  Lingua
//
//  Created by Hoang Ta on 7/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINBadgeCell: UICollectionViewCell {

    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        imageView.image = UIImage(named: "TeachingBadge")
        imageView.frame = bounds
        addSubview(imageView)
    }
    
    override func drawRect(rect: CGRect) {
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

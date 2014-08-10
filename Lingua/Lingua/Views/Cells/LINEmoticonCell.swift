//
//  LINEmoticonCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/10/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINEmoticonCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        imageView.frame = bounds
        addSubview(imageView)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

//
//  LINBadgeHeaderView.swift
//  Lingua
//
//  Created by Hoang Ta on 7/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINBadgeHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.frame = CGRectInset(bounds, 10, 0)
        titleLabel.font = UIFont.appRegularFontWithSize(14)
        addSubview(titleLabel)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

//
//  LINTableViewCell.swift
//  Lingua
//
//  Created by Hoang Ta on 7/12/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINCountryCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor.appTealColor()
        textLabel.font = UIFont.appThinFontWithSize(14)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

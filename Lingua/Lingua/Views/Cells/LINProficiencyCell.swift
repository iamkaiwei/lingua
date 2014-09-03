//
//  LinProficiencyCell.swift
//  Lingua
//
//  Created by Hoang Ta on 7/25/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINProficiencyCell: UITableViewCell {
    private let accessory = UIImageView(image: UIImage(named: "Checked"))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor.appTealColor()
        selectedBackgroundView.alpha = 0
        textLabel?.font = UIFont.appThinFontWithSize(14)
        
        let origin = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(accessory.frame) - 15, CGRectGetHeight(self.frame)/2 - CGRectGetHeight(accessory.frame)/2)
        accessory.frame = CGRect(origin: origin, size: accessory.frame.size)
        accessory.hidden = true
        contentView.addSubview(accessory)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setChecked(check: Bool, animated: Bool) {
        accessory.hidden = !check
        if animated {
            selectedBackgroundView.alpha = 1
            UIView.animateWithDuration(0.5, animations: { self.selectedBackgroundView.alpha = 0 }, completion: { _ in self.selected = false })
        }
    }
    
    override func prepareForReuse() {
        setChecked(false, animated: false)
    }
}

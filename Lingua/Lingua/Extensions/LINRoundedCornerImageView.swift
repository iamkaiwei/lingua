//
//  LINRoundedCornerImageView.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/6/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINRoundedCornerImageView: UIImageView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = CGRectGetWidth(self.frame)/2
        self.layer.masksToBounds = true
    }
}

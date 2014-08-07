//
//  UIImageView+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UIImageView {
    func addRoundedCorner() {
        self.layer.cornerRadius = 24.0
        self.layer.masksToBounds = true
    }
}
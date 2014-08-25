//
//  UIColor-Extensions.swift
//  Lingua
//
//  Created by Hoang Ta on 6/25/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UIColor {
    class func appLightGrayColor() -> UIColor {
        return UIColor(red: 0.8941, green: 0.8941, blue: 0.8941, alpha: 1)
    }
    
    class func appTealColor() -> UIColor {
        return UIColor(red: 0, green: 0.6274, blue: 0.6823, alpha: 1)
    }
    
    class func appRedColor() -> UIColor {
        return UIColor(red: 1, green: 0.4196, blue: 0.4470, alpha: 1)
    }

    class func networkStatusHUDColor() -> UIColor {
        return UIColor(red:177.0/255 , green : 177.0/255 , blue : 177.0/255 , alpha: 1)
    }
    
    class func messageBadgeColor() -> UIColor {
        return UIColor(red:255.0/255 , green : 160.0/255 , blue : 141.0/255 , alpha: 1)
    }
}
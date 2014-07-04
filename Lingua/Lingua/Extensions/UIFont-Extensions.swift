//
//  Font-Extensions.swift
//  Lingua
//
//  Created by Hoang Ta on 6/25/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UIFont {
    class func appBoldFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoSlab-Bold", size: size)
    }
    
    class func appLightFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoSlab-Light", size: size)
    }
    
    class func appRegularFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoSlab-Regular", size: size)
    }
    
    class func appThinFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoSlab-Thin", size: size)
    }
}

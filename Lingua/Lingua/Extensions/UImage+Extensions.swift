//
//  UImage+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/27/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UIImage {
    class func navigationBarBackgroundImage() -> UIImage {
        return imageWithColor(UIColor.appTealColor())
    }

    class func imageWithColor(color:UIColor) -> UIImage {
        var rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func resizableImageWithNewSize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
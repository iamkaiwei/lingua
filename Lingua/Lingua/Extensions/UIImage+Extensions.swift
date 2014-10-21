//
//  UIImage+Extensions.swift
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

    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
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
    
    func LINprofileResizeImage() -> UIImage {
        let w = self.size.width
        let h = self.size.height
        
        let imageRef = self.CGImage
        var width, height: CGFloat
        let destWidth: CGFloat = 200.0
        let destHeight: CGFloat = 200.0
        
        if w > h {
            width = destWidth
            height = h*destWidth/w
        }
        else {
            height = destHeight;
            width = w*destHeight/h
        }
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bitmap = CGBitmapContextCreate(nil, UInt(width), UInt(height), 8, 4 * UInt(width), colorSpace, bitmapInfo)
        
        if self.imageOrientation == .Left {
            CGContextRotateCTM (bitmap, CGFloat(M_PI)/2)
            CGContextTranslateCTM (bitmap, 0, -height)
        }
        else if self.imageOrientation == .Right {
            CGContextRotateCTM (bitmap, CGFloat(-M_PI)/2)
            CGContextTranslateCTM (bitmap, -width, 0)
        }
        else if self.imageOrientation == .Up {
            
        }
        else if self.imageOrientation == .Down {
            CGContextTranslateCTM (bitmap, width,height)
            CGContextRotateCTM (bitmap, CGFloat(-M_PI))
        }
        
        CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef)
        let ref = CGBitmapContextCreateImage(bitmap)
        let result = UIImage(CGImage: ref)!
        
        return result
    }
}
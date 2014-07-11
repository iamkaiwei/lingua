//
//  NSArray-Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension NSArray {
    class func facebookPermissionArray() -> NSArray {
        return ["user_about_me", "email", "user_birthday", "user_location"]
    }
    
    class func quotes() -> (quotes: Array<String>, authors: Array<String>) {
        let path = NSBundle.mainBundle().pathForResource("Quotes", ofType: "txt")
        let fullText = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)!
        let fullArray = fullText.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter{countElements($0) > 0} as [String]
        var quotes = Array<String>()
        var authors = Array<String>()
        for var index = 0; index < fullArray.count; index = index + 2 {
            quotes.append(fullArray[index])
        }
        for var index = 1; index < fullArray.count; index = index + 2 {
            authors.append(fullArray[index])
        }
        return (quotes, authors)
    }
}
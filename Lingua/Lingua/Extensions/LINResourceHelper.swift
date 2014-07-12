//
//  LINResource.swift
//  Lingua
//
//  Created by Hoang Ta on 7/11/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINResourceHelper: NSObject {
    
    class func quotes() -> (quotes: [String], authors: [String]) {
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
    
    class func countryNames() -> [String] {
        struct Static {
            static var instance: [String]?
        }
        if let names = Static.instance {
            return names
        }
        
        var names = [String]()
        for code in NSLocale.ISOCountryCodes() as [String] {
            let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: code])
            let name = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)
            if name != nil {
                names.append(name)
            }
        }
        Static.instance = names.sorted{ (name1: String, name2: String) -> Bool in
            switch name1.localizedCaseInsensitiveCompare(name2) {
            case .OrderedAscending: return true
            default: return false
            }
        }
        return Static.instance!
    }
    
    class func countryNameHeaders() -> [String] {
        struct Static {
            static var instance: [String]?
        }
        
        if let headers = Static.instance {
            return headers
        }
        
        var headers = [String]()
        headers = [String]()
        for name in countryNames() {
            let header = "\(Array(name)[0])"
            if !contains(headers, header) {
                headers.append(header)
            }
        }
        Static.instance = headers
        return headers
    }
}

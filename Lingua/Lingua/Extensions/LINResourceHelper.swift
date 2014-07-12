//
//  LINResource.swift
//  Lingua
//
//  Created by Hoang Ta on 7/11/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINResourceHelper: NSObject {
    
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
    
    class func countryNamesAndCodes() -> (names: Array<String>) {
        var names = Array<String>()
        for code in NSLocale.ISOCountryCodes() as [String] {
            let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: code])
            let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)
            if countryName != nil {
                names.append(countryName)
            }
        }
        return (names.sorted{ (countryName1: String, countryName2: String) -> Bool in
            switch countryName1.localizedCaseInsensitiveCompare(countryName2) {
            case .OrderedAscending: return true
            default: return false
            }
        })
    }
}

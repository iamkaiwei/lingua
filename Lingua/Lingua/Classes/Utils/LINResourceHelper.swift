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
        var quotes = [String]()
        var authors = [String]()
        for var index = 0; index < fullArray.count; index = index + 2 {
            quotes.append(fullArray[index])
        }
        for var index = 1; index < fullArray.count; index = index + 2 {
            authors.append(fullArray[index])
        }
        return (quotes, authors)
    }
    
    class func countryNamesAndHeaders(completion:(names: [String], headers: [String]) -> Void) -> Void {
        struct Static {
            static var instance: ([String], [String])?
        }
        if Static.instance {
            completion(Static.instance!)
        }
        
        var names = [String]()
        for code in NSLocale.ISOCountryCodes() as [String] {
            let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: code])
            let name = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)
            names.append(name)
        }
        names.sort{ n1, n2 in
            switch n1.localizedCaseInsensitiveCompare(n2) {
            case .OrderedAscending: return true
            default: return false
            }
        }
        
        var char: String?
        var headers = names .map { "\(Array($0)[0])" }
                            .filter { if char == nil { char = $0; return true }
                                switch char!.localizedCaseInsensitiveCompare($0) {
                                case .OrderedAscending: char = $0; return true
                                default: return false
                                }
                            }
                
        Static.instance = (names, headers)
        completion(Static.instance!)
    }
}

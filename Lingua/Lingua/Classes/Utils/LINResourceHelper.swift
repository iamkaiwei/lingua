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
    
    class func languages(completion:(languages: [[String]], headers: [String]) -> Void) {
        struct Static {
            static var languages: ([[String]])?
            static var headers: ([String])?
        }
        
        if Static.languages != nil && Static.headers != nil {
            completion(languages: Static.languages!, headers: Static.headers!)
            return
        }
        
        var languages = [String]()
        for code in NSLocale.ISOLanguageCodes() as [String] {
            let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleLanguageCode: code])
            if let language = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier) {
                languages.append(language)
            }
        }
        
        languages.sort{
            switch $0.localizedCaseInsensitiveCompare($1) {
            case .OrderedAscending: return true
            default: return false
            }
        }
        
        //Defensive checking.
        if languages.count < 1 {
            return
        }
        
        var headers = languages.map { "\(Array($0)[0])" }
        var distinctHeaders = [headers[0]] //Initialize with first object from Headers
        var structedArray: [[String]] = [[languages[0]]] //Initialize with first object from Languages
        var structedArrayIndex = structedArray.count - 1
        for var i = 1; i < headers.count; i++ {
            if headers[i] == headers[i - 1] {
                structedArray[structedArrayIndex].append(languages[i])
            }
            else {
                distinctHeaders.append(headers[i])
                var subArray = [languages[i]]
                structedArray.append(subArray)
                structedArrayIndex++
            }
        }
        
        Static.languages = structedArray
        Static.headers = distinctHeaders
        completion(languages: structedArray, headers: distinctHeaders)
    }
}

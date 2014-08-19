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
        let fullText = String.stringWithContentsOfFile(path!, encoding: NSUTF8StringEncoding, error: nil)!
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
    
    class func cachingConversationOfflineData(data:NSData){
        var fullFilePath = getDocumentPathForFile(kCachedConversationDataFile)
        data.writeToFile(fullFilePath, atomically: true)
    }
    
    class func retrievingCachedConversation()->NSData{
        var fullFilePath = getDocumentPathForFile(kCachedConversationDataFile)
        return NSData.dataWithContentsOfFile(fullFilePath, options: NSDataReadingOptions.UncachedRead, error: nil)
    }
    
    //Helper
    class func getDocumentPathForFile(filePath:String)->String{
        var documentPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return "\(documentPath)/\(filePath)"
    }
}

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
        let fullText = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        let fullArray = fullText!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter{countElements($0) > 0} as [String]
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
    
    class func cachingConversationOfflineData(data: NSData) {
        cachingOfflineData(data, filePath: kLINCachedConversationDataFile)
    }
    
    class func retrievingCachedConversation() -> NSData? {
        return retrievingOfflineDataWithFilePath(kLINCachedConversationDataFile)
    }
    
    class func cachingChatHistoryData(conversationId: String, data: NSData) {
        let filePath = String("\(conversationId).\(kLINLinguaResourceExtension)")
        cachingOfflineData(data, filePath: filePath)
    }
    
    class func retrievingChatHistoryData(conversationId: String) -> NSData? {
        let filePath = String("\(conversationId).\(kLINLinguaResourceExtension)")
        return retrievingOfflineDataWithFilePath(filePath)
    }
    
    class func cachingUnsentChatData(conversationId: String, data: NSData) {
        let filePath = String("\(kLINUnsentChatPrefixName)_\(conversationId).\(kLINLinguaResourceExtension)")
        cachingOfflineData(data, filePath: filePath)
    }
    
    class func retrievingUnsentChatData(conversationId: String) -> NSData? {
        let filePath = String("\(kLINUnsentChatPrefixName)_\(conversationId).\(kLINLinguaResourceExtension)")
        return retrievingOfflineDataWithFilePath(filePath)
    }
    
    // MARK: Helpers
    
    class func cachingOfflineData(data: NSData, filePath: String) {
        let fullFilePath = getDocumentPathForFile(filePath)
        data.writeToFile(fullFilePath, atomically: true)
    }
    
    class func retrievingOfflineDataWithFilePath(filePath: String) -> NSData? {
        let fullFilePath = getDocumentPathForFile(filePath)
        return dataFromCachedFile(fullFilePath)
    }
    
    class func dataFromCachedFile(fullFilePath: String) -> NSData? {
        if NSFileManager.defaultManager().fileExistsAtPath(fullFilePath) {
            return NSData(contentsOfFile: fullFilePath, options: NSDataReadingOptions.UncachedRead, error: nil)
        }
        
        return nil
    }
    
    class func getDocumentPathForFile(filePath: String) ->  String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return "\(documentPath)/\(filePath)"
    }
}

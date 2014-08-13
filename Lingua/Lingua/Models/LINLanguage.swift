//
//  LINLanguage.swift
//  Lingua
//
//  Created by Hoang Ta on 8/8/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

func == (left: LINLanguage, right: LINLanguage) -> Bool {
    if left.languageID == -1 { return false }
    return left.languageID == right.languageID
}

class LINLanguage: MTLModel, MTLJSONSerializing {
    var languageID: Int = -1
    var languageName: String = ""
    
    override init() {
        super.init()
    }
    
    class func fromDictionary(dictionary: NSDictionary) -> LINLanguage? {
        let language = LINLanguage()
        if let id = dictionary["_id"] as? Int {
            language.languageID = id
        }
        if let name = dictionary["name"] as? String {
            language.languageName = name
        }
        return language
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer)  {
        super.init(dictionary: dictionaryValue, error: error)
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["languageID": "_id",
                "languageName": "name"]
    }
}

extension LINLanguage {
    class func getLanguages(success: (languages: [[LINLanguage]], headers: [String]) -> Void, failture: (error: NSError?) -> Void) {
        LINNetworkClient.sharedInstance.GET(kLINLanguagePath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                failture(error: error)
                return
            }

            if var languages = (response as OVCResponse).result as? [LINLanguage] {
                languages.sort {
                    switch $0.languageName.localizedCaseInsensitiveCompare($1.languageName) {
                    case .OrderedAscending: return true
                    default: return false
                    }
                }
                var headers = languages.map { "\(Array($0.languageName)[0])" }
                var distinctHeaders = [headers[0]] //Initialize with first object from Headers
                var structedArray: [[LINLanguage]] = [[languages[0]]] //Initialize with first object from Languages
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
                success(languages: structedArray, headers: distinctHeaders)
                return
            }
            
            failture(error: nil)
        })
    }
}
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
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer)  {
        super.init(dictionary: dictionaryValue, error: error)
    }
    
    // MARK: MTLJSONSerializing
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["languageID": "_id",
                "languageName": "name"]
    }
}


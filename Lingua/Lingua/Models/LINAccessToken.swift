//
//  LINAccessToken.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/27/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINAccessToken: MTLModel, MTLJSONSerializing {
    var tokenType: String = ""
    var accessToken: String = ""
    var expiresIn: Int = -1
    var refreshToken: String = ""
    
    init() {
        super.init()
    }
    
    init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer)  {
        super.init(dictionary: dictionaryValue, error: error)
    }
    
    init(tokenType: String, accessToken: String, expiresIn: Int, refreshToken: String) {
        self.tokenType = tokenType
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        
        super.init()
    }
   
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["tokenType": "token_type",
                "accessToken": "access_token",
                "expiresIn": "expires_in",
                "refreshToken": "refresh_token"
        ]
    }
}
//
//  LINUser.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINUser: MTLModel, MTLJSONSerializing {
    var userID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var gender: String = ""
    var avatarURL = ""
    var facebookID = ""
    
    init() {
        super.init()
    }
    
    init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer)  {
        super.init(dictionary: dictionaryValue, error: error)
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["userID": "_id",
                "firstName": "firstname",
                "lastName": "lastname",
                "email": "email",
                "gender": "gender",
                "avatarURL": "avatar_url",
                "facebookID": "facebook_id"
        ]
    }
}
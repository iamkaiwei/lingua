//
//  LINUser.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINUser: MTLModel, MTLJSONSerializing {
    var userId: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var gender: String = ""
    var avatarURL: String = ""
    var facebookID: String = ""
    var deviceToken: String = ""
    var introduction: String = ""
    var nativeLanguage: LINLanguage?
    var learningLanguage: LINLanguage?
    var speakingProficiency: LINProficiency?
    var writingProficiency: LINProficiency?
    
    override init() {
        super.init()
    }
    
    init(userId: String, firstName: String) {
        super.init()
        self.userId = userId
        self.firstName = firstName
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer)  {
        super.init(dictionary: dictionaryValue, error: error)
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["userId": "_id",
                "firstName": "firstname",
                "lastName": "lastname",
                "email": "email",
                "gender": "gender",
                "avatarURL": "avatar_url",
                "facebookID": "facebook_id",
                "deviceToken": "device_token",
                "introduction": "introduction",
                "nativeLanguage": "native_language_id",
                "learningLanguage": "learn_language_id",
                "speakingProficiency": "spoken_proficiency_id",
                "writingProficiency": "written_proficiency_id"
        ]
    }
    
    // MARK: MTLJSONSerializing
    
    class func nativeLanguageJSONTransformer()-> NSValueTransformer {
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(LINLanguage.self)
    }
    
    class func learningLanguageJSONTransformer()-> NSValueTransformer{
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(LINLanguage.self)
    }
    
    class func speakingProficiencyJSONTransformer()-> NSValueTransformer {
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(LINProficiency.self)
    }
    
    class func writingProficiencyJSONTransformer()-> NSValueTransformer {
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(LINProficiency.self)
    }
}
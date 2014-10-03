//
//  LINConversation.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINConversation: MTLModel, MTLJSONSerializing {
    var conversationId: String = ""
    var lastestUpdate: String = ""
    var createdAt: String = ""
    var haveNewMessage : Bool = false
    var teacher :LINUser?
    var learner :LINUser?
    var isLiked : Bool = false
    var isFlagged : Bool = false
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["conversationId": "_id",
                "lastestUpdate": "lastest_update",
                "createdAt": "created_at",
                "teacher":"teacher_id",
                "learner":"learner_id",
                "haveNewMessage":"have_new_messages",
                "isLiked":"isLiked",
                "isFlagged":"isFlagged"
        ]
    }
    
    func getChatUser() -> LINUser {
        var currentUserId = LINUserManager.sharedInstance.currentUser?.userId
        if currentUserId == self.teacher?.userId {
            return learner!
        } else {
            return teacher!
        }
    }
    
    func getOpponentDetail()->(firstName:String , role:String , avatar:NSString){
        var currentUserId = LINUserManager.sharedInstance.currentUser?.userId
        if currentUserId == self.teacher?.userId {
            //the opponent is learner
            return (self.learner!.firstName,self.getOpponentRole(false),self.learner!.avatarURL)
        }
        else
        {
            //the opponent is teacher
            return (self.teacher!.firstName,self.getOpponentRole(true),self.teacher!.avatarURL)
        }
    }
    
    func getOpponentRole(isTeacher:Bool)-> String {
        var language : String = ""
        if isTeacher {
            if self.teacher!.nativeLanguage != nil {
                language = self.teacher!.nativeLanguage!.languageName
            }
            return "Teaching \(language)"
        }
        else
        {
            if self.learner!.learningLanguage != nil {
                language = self.learner!.learningLanguage!.languageName
            }
            return "Learning \(language)"
        }
    }
    
    // MARK: MTLJSONSerializing
    
    class func teacherJSONTransformer()-> NSValueTransformer {
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(LINUser.self)
    }
    
    class func learnerJSONTransformer()-> NSValueTransformer{
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(LINUser.self)
    }
}
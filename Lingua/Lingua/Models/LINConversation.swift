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
    var teacherId: String = ""
    var learnerId: String = ""
    var lastestUpdate: String = ""
    var createdAt: String = ""
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["conversationId": "_id",
                "teacherId": "teacher_id",
                "learnerId": "learner_id",
                "lastestUpdate": "lastest_update",
                "createdAt": "created_at"
        ]
    }
}
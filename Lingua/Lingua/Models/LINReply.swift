//
//  LINReply.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/16/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINReply: MTLModel, MTLJSONSerializing {
    var replyId: String = ""
    var content: String = ""
    var messageTypeId: Int = 1
    var senderId: String = ""
    var conversationId: String = ""
    var createdAt: String = ""
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["replyId": "_id",
                "content": "content",
                "messageTypeId": "message_type_id._id",
                "senderId": "sender_id._id",
                "conversationId": "conversation_id",
                "createdAt": "created_at"
        ]
    }
}
//
//  LINMessage.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINMessage {
    var messageID: String = ""
    var senderUserID: Int = -1
    var content: String = ""
    var messageTypeID: Int = -1
    var createAt: NSDate = NSDate()
    var conversationID: Int = -1
    
    init(content: NSString, createAt: NSDate) {
        self.content = content
        self.createAt = createAt
    }
}
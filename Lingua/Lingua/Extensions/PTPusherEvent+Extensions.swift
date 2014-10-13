//
//  PTPusherEvent+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension PTPusherEvent {
    func getReplyData() -> (userId: String, firstName: String, avatarURL: String, text: String, sendDate: NSDate, type: Int) {
        let data = (self.data as NSDictionary)
        
        let userId = data[kLINUserIdKey] as String
        let firstName = data[kLINFirstName] as String
        let avatarURL = data[kLINAvatarURL] as String
        let text = data[kLINMessageTextKey] as String
        let tmpDate = data[kLINMessageSendDateKey] as String
        let sendDate = NSDateFormatter.iSODateFormatter().dateFromString(tmpDate)
        let type = data[kLINMessageTypeKey] as Int
        
        return (userId, firstName, avatarURL, text, sendDate!, type)
    }
}
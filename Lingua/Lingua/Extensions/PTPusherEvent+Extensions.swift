//
//  PTPusherEvent+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/6/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension PTPusherEvent {
    func getReplyData() -> (userId: String, firstName: String, text: String, sendDate: NSDate) {
        let data = (self.data as NSDictionary)
        let userId = data[kUserIdKey] as String
        let firstName = data[kFirstName] as String
        let text = data[kMessageTextKey] as String
        let tmpDate = data[kMessageSendDateKey] as String
        let sendDate = NSDateFormatter.dateWithDefaultFormatFromString(tmpDate)
        
        return (userId, firstName, text, sendDate)
    }
}
//
//  LINRemoteNotificationHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINRemoteNotificationHelper {
 
    func pushNotificationWithMessage(message: LINMessage, currentUser: LINUser, partnerId: String, conversationId: String) {
        let pushQuery = PFInstallation.query()
        pushQuery.whereKey(kLINUserIdKey, equalTo: partnerId)
        
        var content = message.type.getSubtitleWithText((message.type == LINMessageType.Text) ? message.content as String : "")
        let alertTitle = "\(currentUser.firstName): \(content)"
        
        let push = PFPush()
        push.setData(["aps": ["alert": alertTitle, "sound": "default.m4r"],
                      kLINUserIdKey: currentUser.userId,
                      kLINFirstName: currentUser.firstName,
                      kLINAvatarURL: currentUser.avatarURL,
                      kLINMessageSendDateKey: message.sendDate,
                      kLINMessageTypeKey: message.type.rawValue,
                      kLINConversationIdKey: conversationId])
        push.setQuery(pushQuery)
        
        push.sendPushInBackgroundWithBlock({ (success, error) in
            if success {
                println("[parse] push notification successfully.")
            } else {
                println("[parse] push notification has some errors: \(error!.description)")
            }
        })
    }
}
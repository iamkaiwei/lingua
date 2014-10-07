//
//  LINNotificationHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/8/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINNotificationHelper {
    class func handlePushNotificationWithUserInfo(userInfo: NSDictionary, applicationState: UIApplicationState) {
        let alert = (userInfo["aps"] as NSDictionary)["alert"] as? String
        let userId = userInfo[kUserIdKey] as? String
        let firstName = userInfo[kFirstName] as? String
        let avatarURL = userInfo[kAvatarURL] as? String
        let type = userInfo[kMessageTypeKey] as? Int
        let conversationId = userInfo[kConversationIdKey] as? String
        
        // Only show banner when app is active
        if applicationState == .Active {
            if let tmpId = userId {
                let text = (alert! as NSString).stringByReplacingOccurrencesOfString("\(firstName!):", withString: "") as String
                LINMessageHelper.showNotificationWitUserId(tmpId, name: firstName!, text: text, avatarURL: avatarURL!,
                                                           type: type!, conversationId: conversationId!)
                
                //Post notification for FriendListViewController to update new message counter
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAppReceivedNewMessage, object: conversationId)
                
                LINAudioHelper.sharedInstance.playAlertSound()
            }
        } else if applicationState == .Background || applicationState == .Inactive {
            openChatScreenWithUserId(userId!, name: firstName!, conversationId: conversationId!)
        }
    }
    
    class func openChatScreenWithUserId(userId: String, name: String, conversationId: String) {
        if let homeVC = AppDelegate.sharedDelegate().drawerController.centerViewController as? LINHomeController {
            homeVC.openChatScreenWithUserId(userId, name: name, conversationId: conversationId)
        }
    }
}
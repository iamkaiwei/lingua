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
        let userId = (userInfo as NSDictionary)[kUserIdKey] as? String
        let firstName = (userInfo as NSDictionary)[kFirstName] as? String
        let avatarURL = (userInfo as NSDictionary)[kAvatarURL] as? String
        
        // Only show banner when app is active
        if applicationState == .Active {
            if let tmpId = userId {
                if let tmpuser = LINUserManager.sharedInstance.currentUser {
                    var currentChannel = LINPusherManager.sharedInstance.subcribeToChannelFromUserId(tmpuser.userId, toUserId: tmpId)
                    // Bind to event to receive data
                    currentChannel.bindToEventNamed(kPusherEventNameNewMessage, handleWithBlock: { channelEvent in
                        println("Channel event data: \(channelEvent.data)")
                        let replyData = channelEvent.getReplyData()
                        LINMessageHelper.showNotificationWitUserId(replyData.userId, name: replyData.firstName, text: replyData.text, avatarURL: replyData.avatarURL)
                    })
                }
                
                let text = (alert! as NSString).stringByReplacingOccurrencesOfString(firstName! + ":", withString: "") as String
                LINMessageHelper.showNotificationWitUserId(tmpId, name: firstName!, text: text, avatarURL: avatarURL!)
            }
        } else if applicationState == .Background || applicationState == .Inactive {
            openChatScreenWithUserId(userId!, name: firstName!)
        }
    }
    
    class func openChatScreenWithUserId(userId: String, name: String) {
        let centerViewController = AppDelegate.sharedDelegate().drawerController.centerViewController
        if centerViewController.presentViewController != nil {
            centerViewController.dismissViewControllerAnimated(false, completion: nil)
        }
        
        // Show chat screen
        let chatController = AppDelegate.sharedDelegate().storyboard.instantiateViewControllerWithIdentifier("kLINChatController") as LINChatController
        let user = LINUser(userId: userId, firstName: name)
        chatController.userChat = user
        centerViewController.presentViewController(chatController, animated: true, completion: nil)
    }
}
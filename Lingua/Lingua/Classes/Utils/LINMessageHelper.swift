//
//  LINMessageHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINMessageHelper {
    class func showNotificationWitUserId(userId: String, name: String, text: String, avatarURL: String, type: Int){
        let messageView =  NSBundle.mainBundle().loadNibNamed("LINMessageView", owner: nil, options: nil)[0] as LINMessageView
        messageView.configureWithUserId(userId, name: name, text: text, avatarURL: avatarURL, type: type)
        messageView.showNotification()
    }
}
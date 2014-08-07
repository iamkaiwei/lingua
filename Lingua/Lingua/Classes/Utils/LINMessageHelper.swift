//
//  LINMessageHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINMessageHelper {
    class func showNotificationWithName(name: String, text: String, avatarURL: String){
        let messageView =  NSBundle.mainBundle().loadNibNamed("LINMessageView", owner: nil, options: nil)[0] as LINMessageView
        messageView.configureWithName(name, text: text, avatarURL: avatarURL)
        messageView.showNotification()
    }
}
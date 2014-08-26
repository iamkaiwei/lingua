//
//  LINMessage.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

enum MessageType: Int {
    case Text = 1, Photo, Voice
    func getSubtitleWithText(text: String) -> String {
        var result = ""
        switch self {
        case .Text:
            result = text
        case .Photo:
            result = "Sent you a photo"
        case .Voice:
            result = "Sent you a voice message"
        default:
            break
        }
        return result
    }
}

class LINMessage {
    let incoming: Bool
    let sendDate: NSDate
    var content: AnyObject?
    var url: String?
    var duration: NSTimeInterval = 0  //in seconds, reserved for type voice record.
    var type: MessageType
    
    // Cache height for emoticons textview
    var height: CGFloat?
    
    init(incoming: Bool, sendDate: NSDate, content: AnyObject, type: MessageType) {
        self.incoming = incoming
        self.sendDate = sendDate
        self.type = type
        self.content = content
        
        if type != .Text && content is String {
            self.url = (content as String)
            self.content = nil
        }
    }
}
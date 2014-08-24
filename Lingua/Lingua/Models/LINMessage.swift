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
    var type: MessageType
    
    init(incoming: Bool, sendDate: NSDate, content: AnyObject) {
        self.incoming = incoming
        self.content = content
        self.sendDate = sendDate
        
        if content is String {
            self.type = .Text
        }
        else if content is UIImage {
            self.type = .Photo
        }
        else if content is NSData {
            self.type = .Voice
        }
        else {
            self.type = .Text
            println("There is something wrong...")
        }
    }
    
    init(incoming: Bool, sendDate: NSDate, type: MessageType) {
        self.incoming = incoming
        self.sendDate = sendDate
        self.type = type
    }
}
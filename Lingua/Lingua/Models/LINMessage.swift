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

class LINMessage:NSObject , NSCoding{
    let incoming: Bool = false
    let sendDate: NSDate = NSDate()
    var content: AnyObject?
    var url: String?
    var duration: NSTimeInterval = 0  //in seconds, reserved for type voice record.
    var type: MessageType = MessageType.Text
    
    // Cache height for emoticons textview
    var height: CGFloat = 0
    
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
    
    //NSCoding protocol
    required init(coder aDecoder: NSCoder) {
        self.incoming = aDecoder.decodeBoolForKey("incoming")
        self.sendDate = aDecoder.decodeObjectForKey("sendDate") as NSDate
        self.content  = aDecoder.decodeObjectForKey("content")
        self.url      = aDecoder.decodeObjectForKey("url") as? String
        self.height   = CGFloat(aDecoder.decodeFloatForKey("height"))
        self.duration = aDecoder.decodeObjectForKey("duration") as NSTimeInterval
        self.type     = MessageType.fromRaw(aDecoder.decodeIntegerForKey("type"))!
    }
    
    func encodeWithCoder(encoder: NSCoder){
        encoder.encodeBool(incoming, forKey: "incoming")
        encoder.encodeObject(sendDate, forKey: "sendDate")
        encoder.encodeObject(duration, forKey:"duration")
        encoder.encodeInteger(type.toRaw(), forKey: "type")
        encoder.encodeFloat(Float(height), forKey: "height")
        if content != nil {
            encoder.encodeObject(content!, forKey: "content")
        }
        if url != nil {
            encoder.encodeObject(url!, forKey: "url")
        }
    }
}
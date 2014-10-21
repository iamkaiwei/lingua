//
//  LINMessage.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

enum LINMessageType: Int {
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

enum LINMessageState: Int {
    case Submitted = 1 // The message is waiting to be sent.
    case Sent // The message has sent.
    case UnSent // The message has not been sent.
}

class LINMessage: NSObject, NSCoding {
    var messageId: String?
    var incoming: Bool = false
    var sendDate: NSDate = NSDate()
    var content: AnyObject?
    var url: String?
    var duration: NSTimeInterval = 0  //in seconds, reserved for type voice record.
    var type: LINMessageType = LINMessageType.Text
    var state: LINMessageState = LINMessageState.Submitted
    var downloaded: Bool = false // To know If photo downloaded
    
    // Cache height for emoticons textview
    var height: CGFloat = 0
    
    init(incoming: Bool, sendDate: NSDate, content: AnyObject, type: LINMessageType) {
        self.incoming = incoming
        self.sendDate = sendDate
        self.type = type
        self.content = content
        
        if type != .Text && content is String {
            self.url = (content as String)
            self.content = nil
        }
    }
    
    // NSCoding protocol
    required init(coder aDecoder: NSCoder) {
        self.messageId = aDecoder.decodeObjectForKey("messageId") as? String
        self.incoming = aDecoder.decodeBoolForKey("incoming")
        self.sendDate = aDecoder.decodeObjectForKey("sendDate") as NSDate
        self.content = aDecoder.decodeObjectForKey("content")
        self.url = aDecoder.decodeObjectForKey("url") as? String
        self.height = CGFloat(aDecoder.decodeFloatForKey("height"))
        self.duration = aDecoder.decodeObjectForKey("duration") as NSTimeInterval
        self.type = LINMessageType(rawValue: aDecoder.decodeIntegerForKey("type"))!
        self.state = LINMessageState(rawValue: aDecoder.decodeIntegerForKey("state"))!
    }
    
    func encodeWithCoder(encoder: NSCoder){
        encoder.encodeBool(incoming, forKey: "incoming")
        encoder.encodeObject(sendDate, forKey: "sendDate")
        encoder.encodeObject(duration, forKey:"duration")
        encoder.encodeInteger(type.rawValue, forKey: "type")
        encoder.encodeInteger(state.rawValue, forKey: "state")
        encoder.encodeFloat(Float(height), forKey: "height")
        
        if content != nil {
            encoder.encodeObject(content!, forKey: "content")
        }
        
        if url != nil {
            encoder.encodeObject(url!, forKey: "url")
        }
        
        if messageId != nil {
            encoder.encodeObject(messageId!, forKey: "messageId")
        }
    }
    
    func getHeightForCell() -> CGFloat {
        var result: CGFloat = 0.0
        switch(self.type) {
        case .Text:
            if self.height != 0 {
                result = self.height
            } else {
                result = (self.content! as String).sizeOfStringUseTextStorage().height
            }
            result += kLINTextCellHeightPadding
        case .Photo:
            var imageSize = CGSize()
            if let tmpImageURL = self.url {
                imageSize = CGSize.getSizeFromImageURL(tmpImageURL).scaledSize()
            } else {
                imageSize = (self.content as UIImage).size.scaledSize()
            }
            result = imageSize.height + kLINPhotoCellHeightPadding
        case .Voice:
            result = kLINVoiceMessageMaxHeight
        default:
            break
        }
        return result
    }
}
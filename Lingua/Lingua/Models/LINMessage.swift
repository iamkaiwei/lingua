//
//  LINMessage.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINMessage {
    let incoming: Bool
    let text: String
    let sendDate: NSDate
    let photo: UIImage?
    let type: MessageType
    
    init(incoming: Bool, text: String, sendDate: NSDate, photo: UIImage?, type: MessageType) {
        self.incoming = incoming
        self.text = text
        self.sendDate = sendDate
        self.photo = photo
        self.type = type
    }
}
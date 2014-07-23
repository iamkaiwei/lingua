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
    
    init(incoming: Bool, text: String, sendDate: NSDate) {
        self.incoming = incoming
        self.text = text
        self.sendDate = sendDate
    }
}
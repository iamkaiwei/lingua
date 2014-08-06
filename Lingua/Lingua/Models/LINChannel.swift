//
//  LINChannel.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/6/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINChannel {
    var channel: PTPusherPresenceChannel
    var name: String
    
    init(channel: PTPusherPresenceChannel, name: String) {
        self.channel = channel
        self.name = name
    }
}
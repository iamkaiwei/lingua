//
//  LINChannelManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/6/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

private var channelsArray = [LINChannel]()

class LINChannelManager {
    
    class func addNewChannel(channel: LINChannel) {
        channelsArray.append(channel)
    }
    
    class func updateWithChannel(channel: LINChannel) {
        let index = indexOfChannelByName(channel.name)
        if index >= 0 {
            channelsArray[index] = channel
        }
    }
    
    class private func indexOfChannelByName(name: String) -> Int {
        for i in 0..<channelsArray.count {
            let channel = channelsArray[i]
            if channel.name == name {
                return i
            }
        }
        return -1
    }
    
    class func getChannelByName(name: String) -> LINChannel? {
        for channel in channelsArray {
            if channel.name == name {
                return channel
            }
        }
        return nil
    }
    
    class func unsubscribeAllChannels() {
        for channel in channelsArray {
            channel.channel.unsubscribe()
        }
    }
}
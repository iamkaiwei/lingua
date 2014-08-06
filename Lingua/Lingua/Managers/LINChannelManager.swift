//
//  LINChannelManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/6/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINChannelManager {
    private var channelsArray = [LINChannel]()
    class var sharedInstance: LINChannelManager {
        struct Static {
            static let instance: LINChannelManager = LINChannelManager()
        }
        return Static.instance
    }
    
    func addNewChannel(channel: LINChannel) {
        channelsArray.append(channel)
    }
    
    func updateWithChannel(channel: LINChannel) {
        let index = indexOfChannelByName(channel.name)
        if index >= 0 {
            channelsArray[index] = channel
        }
    }
    
    private func indexOfChannelByName(name: String) -> Int {
        for i in 0..<channelsArray.count {
            let channel = channelsArray[i]
            if channel.name == name {
                return i
            }
        }
        return -1
    }
    
    func getChannelByName(name: String) -> LINChannel? {
        for channel in channelsArray {
            if channel.name == name {
                return channel
            }
        }
        return nil
    }
    
    func unsubscribeAllChannels() {
        for channel in channelsArray {
            channel.channel.unsubscribe()
        }
    }
}
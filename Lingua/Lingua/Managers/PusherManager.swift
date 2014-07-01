//
//  PusherManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/1/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

let kPusherAPIKey = "f67750bab8e68e5f2409"
let kPusherAPIID = "79890"
let kPusherAPISecret = "a4b6be34cce67b8a8ec7"

class PusherManager : NSObject {
//    var pusherClient : PTPusher
    
    class var sharedInstance : PusherManager {
        struct Static {
            static let instance : PusherManager = PusherManager()
        }
        return Static.instance;
    }

//    init() {
//        pusherClient = PTPusher.pusherWithKey(kPusherAPIKey, delegate: self, encrypted: true)
//    }
}
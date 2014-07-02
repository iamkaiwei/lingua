//
//  PusherManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/1/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

// Global constants
let kPusherAPIKey = "f67750bab8e68e5f2409"
let kPusherAPIID = "79890"
let kPusherAPISecret = "a4b6be34cce67b8a8ec7"
let kPuserAuthorizationURL = "http://pusher-chat-server.herokuapp.com/pusher/auth"


class PusherManager : NSObject, PTPusherDelegate {
    var pusherClient : PTPusher = PTPusher()
    
    class var sharedInstance : PusherManager {
        get {
            struct Static {
                static let instance : PusherManager = PusherManager()
            }
            return Static.instance;
        }
    }

    init() {
        super.init()
        
        pusherClient = PTPusher.pusherWithKey(kPusherAPIKey, delegate: self, encrypted: true) as PTPusher
        pusherClient.authorizationURL = NSURL.URLWithString(kPuserAuthorizationURL)
    }
    
    func connectToPusher() {
        pusherClient.connect()
    }
    
    
    // MARK: PTPusherDelegate
    
    func pusher(pusher: PTPusher, connectionWillConnect connection: PTPusherConnection) -> Bool {
        println("[pusher] Pusher client connecting...");
        return true;
    }
    
    func pusher(pusher: PTPusher, connectionDidConnect connection: PTPusherConnection) {
        println("[pusher-\(connection.socketID)] Pusher client connected");
    }
    
    func pusher(pusher: PTPusher, connection: PTPusherConnection, failedWithError error: NSError ) {
        println("[pusher] Pusher Connection failed with error: \(error)");
    }

}
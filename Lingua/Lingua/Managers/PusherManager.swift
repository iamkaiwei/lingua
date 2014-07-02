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
        
        self.pusherClient = PTPusher.pusherWithKey(kPusherAPIKey, delegate: self, encrypted: true) as PTPusher
        self.pusherClient.authorizationURL = NSURL.URLWithString(kPuserAuthorizationURL)
    }
    
    func connectToPusher() {
        self.pusherClient.connect()
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
        
        if error.domain == kCFErrorDomainCFNetwork {
            self.startReachabilityCheck()
        }
    }
    
    func pusher(pusher: PTPusher, connection: PTPusherConnection, didDisconnectWithError error: NSError, willAttemptReconnect: Bool) {
        println("[pusher-\(pusher.connection.socketID)] Pusher Connection disconnected with error: \(error)");
        
        if (willAttemptReconnect) {
            println("[pusher-\(pusher.connection.socketID)] Client will attempt to reconnect automatically");
        } else {
            if error.domain != PTPusherErrorDomain {
                self.startReachabilityCheck()
            }
        }
    }
    
    func pusher(pusher: PTPusher, connectionWillAutomaticallyReconnect connection: PTPusherConnection, afterDelay delay: NSTimeInterval) -> Bool {
        println("[pusher-\(pusher.connection.socketID)] Client automatically reconnecting after \(delay) seconds...")
        return true;
    }
    
    // MARK - Reachability
    
    func startReachabilityCheck() {
        let reachability : Reachability = Reachability(hostname: pusherClient.connection.URL.host)
        if reachability.isReachable() {
            println("Internet reachable, reconnecting")
            self.connectToPusher()
        } else {
            println("Waiting for reachability");

            let reachableBlock = { (reachability : Reachability) -> Void in
                if reachability.isReachable() {
                    println("Internet is now reachable")
                    reachability.stopNotifier()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.connectToPusher()
                    })
                }
            }
            
            // reachability.reachableBlock = reachableBlock
            reachableBlock(reachability)
            
            reachability.startNotifier()
        }
    }
    
}
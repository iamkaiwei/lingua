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
    
    
    // PTPusherDelegate
    
    func pusher(pusher: PTPusher, connectionWillConnect connection: PTPusherConnection) -> Bool {
        println("[pusher] Pusher client connecting...");
        return true;
    }
    
    func pusher(pusher: PTPusher, connectionDidConnect connection: PTPusherConnection) {
        println("[pusher-\(connection.socketID)] Pusher client connected");
    }
    
    func pusher(pusher: PTPusher, connection: PTPusherConnection, failedWithError error: NSError) {
        println("[pusher] Pusher Connection failed with error: \(error)");
        
        if error.domain == kCFErrorDomainCFNetwork {
            startReachabilityCheck()
        }
    }
    
    func pusher(pusher: PTPusher, connection: PTPusherConnection, didDisconnectWithError error: NSError, willAttemptReconnect: Bool) {
        println("[pusher-\(pusher.connection.socketID)] Pusher Connection disconnected with error: \(error)");
        
        if (willAttemptReconnect) {
            println("[pusher-\(pusher.connection.socketID)] Client will attempt to reconnect automatically");
        } else {
            if error.domain != String(PTPusherErrorDomain) {
                startReachabilityCheck()
            }
        }
    }
    
    func pusher(pusher: PTPusher, connectionWillAutomaticallyReconnect connection: PTPusherConnection, afterDelay delay: NSTimeInterval) -> Bool {
        println("[pusher-\(pusher.connection.socketID)] Client automatically reconnecting after \(delay) seconds...")
        return true;
    }
    
    // Subcribe to channel delegate
    
    func pusher(pusher: PTPusher, didSubscribeToChannel channel: PTPusherChannel) {
        println("[pusher-\(pusher.connection.socketID)] Subscribed to channel \(channel)");
    }
    
    func pusher(pusher: PTPusher, didFailToSubscribeToChannel channel: PTPusherChannel, withError error: NSError) {
        println("[pusher-\(pusher.connection.socketID)] Authorization failed for channel \(channel)");
        
        let alert : UIAlertView = UIAlertView(title: "Authorization Failed", message: "Client with socket ID \(pusher.connection.socketID) could not be authorized to join channel \(channel.name)", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func pusher(pusher: PTPusher, willAuthorizeChannel channel: PTPusherChannel, withRequest request: NSMutableURLRequest) {
        println("[pusher-\(pusher.connection.socketID)] Authorizing channel access...");
        
        request.setValue("Bearer \(PFUser.currentUser().sessionToken)", forHTTPHeaderField: "Authorization");
    }
    
    // Reachability
    
    func startReachabilityCheck() {
        let reachability : Reachability = Reachability(hostname: pusherClient.connection.URL.host)
        if reachability.isReachable() {
            println("Internet reachable, reconnecting")
            connectToPusher()
        } else {
            println("Waiting for reachability");

            reachability.reachableBlock = { (reachability : Reachability?) -> Void in
                if reachability?.isReachable() {
                    println("Internet is now reachable")
                    
                    reachability?.stopNotifier()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.connectToPusher()
                    })
                }
            }
            
            reachability.startNotifier()
        }
    }
}
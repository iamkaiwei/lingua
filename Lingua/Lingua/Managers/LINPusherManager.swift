//
//  PusherManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/1/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

// Global constants
let kPusherAPIKey = "760826ac4922c8b7563a"
let kPusherAPIID = "76720"
let kPusherAPISecret = "b0d277089fc2d751fb8a"
let kPuserAuthorizationURL = "http://pusher-chat-server.herokuapp.com/pusher/auth"


class LINPusherManager : NSObject, PTPusherDelegate, PTPusherPresenceChannelDelegate {
    var pusherClient : PTPusher = PTPusher()
    
    class var sharedInstance : LINPusherManager {
        struct Static {
            static let instance : LINPusherManager = LINPusherManager()
        }
        return Static.instance;
    }

    override init() {
        super.init()
        
        pusherClient = PTPusher.pusherWithKey(kPusherAPIKey, delegate: self, encrypted: true) as PTPusher
        pusherClient.authorizationURL = NSURL.URLWithString(kPuserAuthorizationURL)
    }
    
    // MARK: Pusher utils
    
    func connectToPusher() {
        pusherClient.connect()
    }
    
    func subscribeToPresenceChannelNamed(name: String) -> PTPusherPresenceChannel {
        return pusherClient.subscribeToPresenceChannelNamed(name, delegate: self)
    }
    
    func generateUniqueChannelNameFromUserId(fromUserId: String, toUserId: String) -> String {
        var channelName = ""
        if fromUserId.compare(toUserId, options: NSStringCompareOptions.CaseInsensitiveSearch) == NSComparisonResult.OrderedAscending {
            channelName = "\(fromUserId)-\(toUserId)"
        } else {
            channelName = "\(toUserId)-\(fromUserId)"
        }
        
        return channelName
    }
    
    // MARKL: Presence channel events
    
    func presenceChannelDidSubscribe(channel: PTPusherPresenceChannel!) {
        println("[pusher] Channel members: \(channel.members)")
    }
    
    func presenceChannel(channel: PTPusherPresenceChannel!, memberAdded member: PTPusherChannelMember!) {
        println("[pusher] Member joined channel: \(member)")
    }
    
    func presenceChannel(channel: PTPusherPresenceChannel!, memberRemoved member: PTPusherChannelMember!) {
        println("[pusher] Member left channel: \(member)")
    }

    // MARK: PTPusher Delegate
    
    func pusher(pusher: PTPusher, connectionWillConnect connection: PTPusherConnection) -> Bool {
        println("[pusher] Pusher client connecting...")
        return true;
    }
    
    func pusher(pusher: PTPusher, connectionDidConnect connection: PTPusherConnection) {
        println("[pusher-\(connection.socketID)] Pusher client connected")
    }
    
    func pusher(pusher: PTPusher, connection: PTPusherConnection, failedWithError error: NSError) {
        println("[pusher] Pusher Connection failed with error: \(error)")
        
        if (error.domain as NSString) == kCFErrorDomainCFNetwork {
            startReachabilityCheck()
        }
    }
    
    func pusher(pusher: PTPusher, connection: PTPusherConnection, didDisconnectWithError error: NSError, willAttemptReconnect: Bool) {
        println("[pusher-\(pusher.connection.socketID)] Pusher Connection disconnected with error: \(error)")
        
        if (willAttemptReconnect) {
            println("[pusher-\(pusher.connection.socketID)] Client will attempt to reconnect automatically")
        } else {
            if error.domain != String(format: PTPusherErrorDomain) {
                startReachabilityCheck()
            }
        }
    }
    
    func pusher(pusher: PTPusher, connectionWillAutomaticallyReconnect connection: PTPusherConnection, afterDelay delay: NSTimeInterval) -> Bool {
        println("[pusher-\(pusher.connection.socketID)] Client automatically reconnecting after \(delay) seconds...")
        return true;
    }
    
    // MARK: Subcribed to channel delegate
    
    func pusher(pusher: PTPusher, didSubscribeToChannel channel: PTPusherChannel) {
        println("[pusher-\(pusher.connection.socketID)] Subscribed to channel \(channel)")
    }
    
    func pusher(pusher: PTPusher, didFailToSubscribeToChannel channel: PTPusherChannel, withError error: NSError) {
        println("[pusher-\(pusher.connection.socketID)] Authorization failed for channel \(channel)")
        
        let alert : UIAlertView = UIAlertView(title: "Authorization Failed", message: "Client with socket ID \(pusher.connection.socketID) could not be authorized to join channel \(channel.name)", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func pusher(pusher: PTPusher, willAuthorizeChannel channel: PTPusherChannel, withRequest request: NSMutableURLRequest) {
        println("[pusher-\(pusher.connection.socketID)] Authorizing channel access...")
        
        request.setValue("Bearer \(LINFacebookManager.sharedInstance.facebookToken)", forHTTPHeaderField: "Authorization")
    }
    
    // MARK: Reachability
    
    func startReachabilityCheck() {
        let reachability : Reachability = Reachability(hostname: pusherClient.connection.URL.host)
        if reachability.isReachable() {
            println("Internet reachable, reconnecting")
            connectToPusher()
        } else {
            println("Waiting for reachability");

            reachability.reachableBlock = { (reachability : Reachability?) -> Void in
                if reachability?.isReachable() != nil {
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
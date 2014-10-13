//
//  LINPusherChannel.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINPusherChannel {
    var presenceChannel: PTPusherPresenceChannel?
    var channelName: String?
    
    init() {
        presenceChannel = PTPusherPresenceChannel()
    }
    
    func unsubscribe() {
        presenceChannel?.unsubscribe()
    }
    
    func subcribe(#fromUserId: String, toUserId: String, delegate: PTPusherPresenceChannelDelegate) {
        if channelName == nil {
            channelName = generateUniqueChannelName(fromUserId: fromUserId, toUserId: toUserId)
        }
                                
        unsubscribe()
        presenceChannel = LINPusherManager.sharedInstance.subscribeToPresenceChannelNamed(channelName!, delegate: delegate)
    }
    
    func receivedMessage(#completion: (message: LINMessage) -> Void) {
        presenceChannel?.bindToEventNamed(kPusherEventNameNewMessage, handleWithBlock: { channelEvent in
            let replyData = channelEvent.getReplyData()
            let type = MessageType.fromRaw(replyData.type)
            
            let aMessage = LINMessage(incoming: true, sendDate: replyData.sendDate, content: replyData.text, type: type!)
            aMessage.state = MessageState.Sent
            
            completion(message: aMessage)
        })
    }
    
    func sendMessage(#currentUser: LINUser, text: String, sendDate: String, messageType: MessageType) {
        presenceChannel?.triggerEventNamed(kPusherEventNameNewMessage,
                                           data: [kUserIdKey: currentUser.userId,
                                                  kFirstName: currentUser.firstName,
                                                  kAvatarURL: currentUser.avatarURL,
                                                  kMessageTextKey: text,
                                                  kMessageSendDateKey: sendDate,
                                                  kMessageTypeKey: messageType.toRaw()
                                           ])
    }
    
    // MARK: Utility methods
    
    private func generateUniqueChannelName(#fromUserId: String, toUserId: String) -> String {
        var channelName = ""
        if fromUserId.compare(toUserId, options: .CaseInsensitiveSearch) == NSComparisonResult.OrderedAscending {
            channelName = "\(fromUserId)-\(toUserId)"
        } else {
            channelName = "\(toUserId)-\(fromUserId)"
        }
        
        return channelName
    }
}
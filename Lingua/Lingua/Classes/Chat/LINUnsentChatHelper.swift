//
//  LINUnsentChatHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/10/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINUnsentChatHelper {
    var unsentMessagesArray = [LINMessage]()
    var conversationId: String = ""
    
    // MARK: Cached data
    
    func cachingUnsentChatData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let data = NSKeyedArchiver.archivedDataWithRootObject(self.unsentMessagesArray)
            LINResourceHelper.cachingUnsentChatData(self.conversationId, data: data)
        })
    }
    
    func loadCachedUnsentChatData() {
        let cachedData = LINResourceHelper.retrievingUnsentChatData(self.conversationId)
        if cachedData != nil {
            if let tmpUnsentMessagesArray = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!) as? [LINMessage] {
                unsentMessagesArray = tmpUnsentMessagesArray
            }
        }
    }
    
    // MARK: Unsents chat
    
    func getListUnsentsChat(#minSendDate: NSDate, maxSendDate: NSDate, currentPageIndex: Int) -> [LINMessage] {
        var unsentsChatTemp = [LINMessage]()
        for message in unsentMessagesArray {
            let timeInterval = message.sendDate.timeIntervalSince1970
            
            if currentPageIndex == kLINChatHistoryBeginPageIndex {
                if timeInterval > minSendDate.timeIntervalSince1970 {
                    unsentsChatTemp.append(message)
                }
            } else {
                if timeInterval > minSendDate.timeIntervalSince1970 && timeInterval < maxSendDate.timeIntervalSince1970 {
                    unsentsChatTemp.append(message)
                }
            }
        }
        
        return unsentsChatTemp
    }
    
    func getMessageIndex(#messageId: String) -> Int {
        for (index, message) in enumerate(unsentMessagesArray) {
            if message.messageId == messageId {
                return index
            }
        }
        
        return -1
    }
    
    func removeMessage(#messageId: String) {
        let index = getMessageIndex(messageId: messageId)
        if index >= 0 {
            unsentMessagesArray.removeAtIndex(index)
        }
    }
    
    func addMessage(message: LINMessage) {
        let index = getMessageIndex(messageId: message.messageId!)
        if index >= 0 {
            unsentMessagesArray.removeAtIndex(index)
        }
        
        unsentMessagesArray.append(message)
    }
    
    func addOrRemoveMessage(#message: LINMessage) {
        if message.state == LINMessageState.UnSent {
            addMessage(message)
        } else if message.state == LINMessageState.Sent {
            removeMessage(messageId: message.messageId!)
        }
    }
}
//
//  LINChatHistoryHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

let kLINMaxRepliesPerConversation = 20

class LINChatHistoryHelper {
    var messagesArray = [LINMessage]()
    var repliesArray = [AnyObject]()
    var conversationId: String = ""
    var currentUserId: String = ""
    
    // MARK: Messages array
    
    func getMessageById(messageId: String) -> (index: Int, message: LINMessage)? {
         for (index, message) in enumerate(messagesArray) {
            if message.messageId == messageId {
                return (index, message)
            }
        }
        return nil
    }
    
    func sortMessagesArrayAccordingToSendDate() {
        messagesArray.sort{ $0.sendDate.timeIntervalSince1970 < $1.sendDate.timeIntervalSince1970 }
    }
    
    func getHeightForCellAtIndex(index: Int) -> CGFloat {
        let message = messagesArray[index]
        return message.getHeightForCell()
    }
    
    func moveMessageToIndex(index: Int) {
        let message = messagesArray[index]
        message.state = LINMessageState.Submitted
        message.sendDate = NSDate()
        
        messagesArray.removeAtIndex(index)
        messagesArray.append(message)
    }
    
    func mixAnUnsentMessages(unsentMessagesArray: [LINMessage]) {
        if unsentMessagesArray.count > 0 {
            messagesArray += unsentMessagesArray
            sortMessagesArrayAccordingToSendDate()
        }
    }
    
    // MARK: Replies array

    func addNewReply(replyDict: AnyObject) {
        repliesArray.append(replyDict)
    }
    
    func shouldPostRepliesArrayToServer() {
        if repliesArray.count == kLINMaxRepliesPerConversation {
            postMessagesToServer()
        }
    }
    
    // MARK: Network requests
    
    func postMessagesToServer() {
        if repliesArray.count <= 0 {
            return
        }
        
        LINNetworkClient.sharedInstance.creatBulkWithConversationId(self.conversationId,
            messagesArray: repliesArray) {
                (success) -> Void in
                if success {
                    self.repliesArray.removeAll(keepCapacity: false)
                }
        }
    }
    
    func loadChatHistoryWithLenght(lenght: Int, page: Int, completion: (repliesArray: [LINReply]?) -> Void) {
        LINNetworkClient.sharedInstance.getChatHistoryWithConversationId(self.conversationId, length: lenght, page: page) {
            (repliesArray, error) -> Void in
            if error != nil {
                completion(repliesArray: nil)
                return
            }
            
            if let tmpRepliesArray = repliesArray {
                for reply in tmpRepliesArray  {
                    var incoming = true
                    if reply.senderId == self.currentUserId {
                        incoming = false
                    }
                    
                    let aMessage = LINMessage(incoming: incoming,
                                              sendDate: NSDateFormatter.iSODateFormatter().dateFromString(reply.createdAt)!,
                                              content: reply.content,
                                              type: LINMessageType.fromRaw(reply.messageTypeId)!)
                    aMessage.state = LINMessageState.Sent
                    self.messagesArray.insert(aMessage, atIndex: 0)
                }
                
                if tmpRepliesArray.count > 0 {
                    completion(repliesArray: tmpRepliesArray)
                } else {
                    completion(repliesArray: nil)
                }
            }
        }
    }

    // MARK: Cached data
    
    func cachingChatHistoryData() {
        let lastestMessagesArray = getLastestMessages()
        
        if lastestMessagesArray != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let chatHistoryData = NSKeyedArchiver.archivedDataWithRootObject(lastestMessagesArray!)
                LINResourceHelper.cachingChatHistoryData(self.conversationId, data: chatHistoryData)
            })
        }
    }
    
    func loadCachedChatHistory() {
        let cachedData = LINResourceHelper.retrievingChatHistoryData(self.conversationId)
        if cachedData != nil {
            if let tmpMessagesArray = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!) as? [LINMessage] {
                messagesArray = tmpMessagesArray
            }
        }
    }
    
    // MARK: Utility methods
    
    private func getLastestMessages() -> [LINMessage]? {
        let numberOfMessage = min(messagesArray.count, kLINChatHistoryMaxLenght)
        if numberOfMessage == 0 {
            return nil
        }
        
        let messageCount = messagesArray.count
        let startIndex: Int = abs(messageCount - numberOfMessage)
        let endIndex: Int = messageCount - 1
        let lastestMessages = Array(messagesArray[startIndex...endIndex]) as [LINMessage]
        
        return lastestMessages
    }
}
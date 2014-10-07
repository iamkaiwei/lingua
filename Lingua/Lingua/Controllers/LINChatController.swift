//
//  LINChatController.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/14/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation
import QuartzCore

let kPusherEventNameNewMessage = "client-chat";
let kChatHistoryBeginPageIndex = 1
let kChatHistoryMaxLenght = 20

enum LINChatMode {
    case Online, Offline
}

protocol LINChatControllerDelegate {
    func chatControllerShouldMoveConversationToTheTop(conversationId: String) -> Void
}

class LINChatController: LINViewController, UITableViewDelegate {
    @IBOutlet weak var composeBar: LINComposeBarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topNavigationView: LINTopNavigationView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    private var pullRefreshControl = UIRefreshControl()
    private var messageArray = [LINMessage]()
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    private var onPlayVoiceMessage: LINMessage?
    
    private var currentChannel = PTPusherPresenceChannel()
    private var conversationChanged = false
    var delegate: LINChatControllerDelegate?

    var conversation: LINConversation = LINConversation() {
        didSet {
            userChat = conversation.getChatUser()
            conversationId = conversation.conversationId
        }
    }
    var conversationId: String = ""
    var userChat = LINUser()
    
    private var currentUser = LINUser()
    private var repliesArray = [AnyObject]()
    private var currentPageIndex = kChatHistoryBeginPageIndex
    private var currentChatMode = LINChatMode.Offline
    
    // Unsent messages
    private var unsentMessagesArray = [LINMessage]()

    // Layout contraints
    @IBOutlet weak var composeBarBottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeBarHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        composeBar.delegate = self
        LINPusherManager.sharedInstance.delegate = self
        
        configureUI()
        setupTableView()
        
        loadCachedUnsentChatData()
        
        if LINNetworkHelper.isReachable() {
            loadListLastestMessages()
        } else {
            loadingCachedChatHistory()
        }
        
        setupNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.topNavigationView.checkingConnectionStatus()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToPresenceChannel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        appDidEnterBackground()

        // Call previous view controller to re-arrange the order
        if conversationChanged {
            self.delegate?.chatControllerShouldMoveConversationToTheTop(conversationId)
        }

        // Stop audio helper
        LINAudioHelper.sharedInstance.stopPlaying()
    }
    
    // MARK: Configuration
    
    private func configureUI() {
        pullRefreshControl.addTarget(self, action: Selector("loadOlderMessages"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(pullRefreshControl)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
        tableView.addGestureRecognizer(tapGesture)
        
        if let tmpuser = LINUserManager.sharedInstance.currentUser {
            currentUser = tmpuser
        }
        
        nameLabel.text = userChat.firstName
        likeButton.selected = conversation.isLiked
        flagButton.selected = conversation.isFlagged
    }
    
    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomActive", name: kNotificationAppDidBecomActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: kNotificationAppDidEnterBackground, object: nil)
        
        topNavigationView.registerForNetworkStatusNotification(lostConnection: kNotificationAppDidLostConnection, restoreConnection: kNotificationAppDidRestoreConnection)
        tableView.registerForNetworkStatusNotification(lossConnection: kNotificationAppDidLostConnection, restoreConnection: kNotificationAppDidRestoreConnection)
    }
    
    func didTapOnTableView(sender: UITapGestureRecognizer) {
        composeBar.hide()
    }
    
    private func setupTableView() {
        let configureClosure: TableViewCellConfigureClosure = { (bubbleCell, message, indexPath) -> Void in
            let bubbleCell = (bubbleCell as LINBubbleCell)
            bubbleCell.delegate = self
            bubbleCell.configureCellWithMessage(message as LINMessage)
            
            if let tempMessage = self.onPlayVoiceMessage {
                if message === tempMessage {
                    LINAudioHelper.sharedInstance.playerDelegate = bubbleCell
                }
            }
        }
        
        dataSource = LINArrayDataSource(items: messageArray, cellIdentifier: cellIdentifier, configureClosure: configureClosure)
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0)
        tableView.registerClass(LINBubbleCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    // MARK: UITableviewDelegate
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return heightForCellAtIndexPath(indexPath)
    }
    
    // MARK: Actions
    
    @IBAction func backButtonTouched(sender: UIButton) {
        composeBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFlagButton(sender: UIButton) {
        onAction(likeButtonTouched: false, sender: sender)
    }
    
    @IBAction func onLikeButton(sender: UIButton) {
        onAction(likeButtonTouched: true, sender: sender)
    }
    
    // MARK: Utility Methods
    
    private func onAction(#likeButtonTouched: Bool, sender: UIButton) {
        var actionType: LINActionType
        let isOn: Bool = !sender.selected
        
        if likeButtonTouched {
            actionType = isOn == true ? .LINActionTypeLike : .LINActionTypeUnLike
        } else {
            actionType = isOn == true ? .LINActionTypeFlag : .LINActionTypeUnFlag
        }
        
        LINNetworkClient.sharedInstance.callActionAPI(actionType, userId: userChat.userId, {(error) -> Void in
            if error == nil {
                println("Action completed successfully")
                sender.selected = isOn
                
                if likeButtonTouched {
                    self.conversation.isLiked = isOn
                } else {
                    self.conversation.isFlagged = isOn
                }
            } else {
                println("Action got error : \(error?.localizedDescription)")
            }
        })
    }
    
    private func leaveConversation() {
        LINNetworkClient.sharedInstance.leaveConversationWithConversationId(conversationId, completion: { (success) -> Void in })
    }
    
    func appDidEnterBackground() {
        leaveConversation()
        currentChannel.unsubscribe()
        postMessagesToServer()
        cachingChatHistoryData()
        cachingUnsentChatData()
    }
    
    func appDidBecomActive() {
        subscribeToPresenceChannel()
        loadListLastestMessages()
        LINAudioHelper.sharedInstance.cancelRecording()
    }
    
    private func pushNotificationWithMessage(message: LINMessage) {
        // Create our Installation query
        let pushQuery = PFInstallation.query()
        pushQuery.whereKey(kUserIdKey, equalTo: userChat.userId)
        
        var content = message.type.getSubtitleWithText((message.type == MessageType.Text) ? message.content as String : "")
        let alertTitle = "\(currentUser.firstName): \(content)"
        
        let push = PFPush()
        push.setData(["aps": ["alert": alertTitle, "sound": "default.m4r"],
                     kUserIdKey: currentUser.userId,
                     kFirstName: currentUser.firstName,
                     kAvatarURL: currentUser.avatarURL,
                     kMessageSendDateKey: message.sendDate,
                     kMessageTypeKey: message.type.toRaw(),
                     kConversationIdKey: conversationId])
        push.setQuery(pushQuery)
        
        push.sendPushInBackgroundWithBlock({ (success, error) in
            if success {
                println("[parse] push notification successfully.")
            } else {
                println("[parse] push notification has some errors: \(error!.description)")
            }
        })
    }
    
    private func postMessagesToServer() {
        if repliesArray.count <= 0 {
            return
        }
        
        LINNetworkClient.sharedInstance.creatBulkWithConversationId(conversationId,
            messagesArray: repliesArray) {
                (success) -> Void in
                if success {
                    self.repliesArray.removeAll(keepCapacity: false)
                }
        }
    }
    
    private func addBubbleViewCellWithMessage(message: LINMessage) {
        // Update data source
        messageArray.append(message)
        dataSource!.items = messageArray
        
        let indexPaths = [NSIndexPath(forRow: messageArray.count - 1, inSection: 0)]
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    private func moveBubbleCellToBottomAtIndexPath(indexPath: NSIndexPath) {
        let message = messageArray[indexPath.row]
        message.state = MessageState.Submitted
        message.sendDate = NSDate()
        
        // Update data source
        messageArray.removeAtIndex(indexPath.row)
        messageArray.append(message)
        dataSource!.items = messageArray

        let toIndexPath = NSIndexPath(forRow: messageArray.count - 1, inSection: 0)
        
        tableView.beginUpdates()
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: toIndexPath)
        tableView.endUpdates()
        
        tableView.reloadRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.None)
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    private func updateMessageWithNewState(state: MessageState, messageId: String) {
        for (index, message) in enumerate(messageArray) {
            if message.messageId == messageId {
                message.state = state
                
                let indexPaths = [NSIndexPath(forRow: index, inSection: 0)]
                
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
                
                // Add un-sent message to an array
                if state == MessageState.UnSent {
                    addToUnsentMessagesArrayWithMessage(message)
                } else if state == MessageState.Sent && unsentMessagesArray.count > 0 {
                    removeMessageFromUnsentMessagesArrayWithMessageId(messageId)
                }
                break
            }
        }
    }
    
    private func addListBubbleCellsWithCount(count: Int) {
        var contentOffset = self.tableView.contentOffset
        tableView.reloadData()
        
        var heightForNewRows: CGFloat = 0
        for var i = 0; i < count; i++ {
            heightForNewRows += heightForCellAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
        }
        
        contentOffset.y += heightForNewRows
        
        // Keep uitableview static when inserting rows at the top
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    private func heightForCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        let message = messageArray[indexPath.row]
        return message.getHeightForCell()
    }
    
    private func loadListLastestMessages() {
        loadChatHistoryWithLenght(kChatHistoryMaxLenght, page: currentPageIndex)
    }
    
    // KTODO: Refator - Long method

    private func loadChatHistoryWithLenght(lenght: Int, page: Int) {
        LINNetworkClient.sharedInstance.getChatHistoryWithConversationId(conversationId,
            length: lenght,
            page: page) {
                (repliesArray, error) -> Void in
                if let tmpRepliesArray = repliesArray {
                    for reply in tmpRepliesArray  {
                        var incoming = true
                        if reply.senderId == self.currentUser.userId {
                            incoming = false
                        }
                        
                        let aMessage = LINMessage(incoming: incoming,
                                                  sendDate: NSDateFormatter.iSODateFormatter().dateFromString(reply.createdAt)!,
                                                  content: reply.content,
                                                  type: MessageType.fromRaw(reply.messageTypeId)!)
                        aMessage.state = MessageState.Sent
                        self.messageArray.insert(aMessage, atIndex: 0)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        if tmpRepliesArray.count > 0 {
                            // Load un-sents chat
                            let maxSendDate = NSDateFormatter.iSODateFormatter().dateFromString(tmpRepliesArray.first!.createdAt)
                            let minSendDate = NSDateFormatter.iSODateFormatter().dateFromString(tmpRepliesArray.last!.createdAt)
                            let unsentsChatTemp = self.getListUnsentsChatWithMinSendDate(minSendDate!, maxSendDate: maxSendDate!)
                            if unsentsChatTemp.count > 0 {
                                self.messageArray += unsentsChatTemp
                                self.sortMessagesArrayAccordingToSendDate()
                            }
                            
                            // Update data source and reload tableview
                            self.dataSource!.items = self.messageArray
                            
                            if self.currentPageIndex == kChatHistoryBeginPageIndex {
                                self.tableView.reloadData()
                                self.scrollBubbleTableViewToBottomAnimated(true)
                            } else {
                                self.addListBubbleCellsWithCount(tmpRepliesArray.count)
                            }
                            
                            self.currentPageIndex++
                            
                            if page == kChatHistoryBeginPageIndex {
                                self.cachingChatHistoryData()
                            }
                        }
                        self.pullRefreshControl.endRefreshing()
                    }
                }
        }
    }
    
    func getLastestMessages() -> [LINMessage]? {
        let numberOfMessage = min(self.messageArray.count, kChatHistoryMaxLenght)
        if numberOfMessage == 0 {
            return nil
        }
        let messageCount = self.messageArray.count
        let startIndex:Int = abs(messageCount - numberOfMessage)
        let endIndex:Int = messageCount - 1
        let lastestMessages = Array(self.messageArray[startIndex...endIndex]) as [LINMessage]
        return lastestMessages
    }
    
    func loadOlderMessages() {
        loadChatHistoryWithLenght(kChatHistoryMaxLenght, page: currentPageIndex)
    }
    
    private func scrollBubbleTableViewToBottomAnimated(animated: Bool) {
        let lastRowIdx = messageArray.count - 1
        if lastRowIdx >= 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIdx, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
    
    private func subscribeToPresenceChannel() {
        let channelName = generateUniqueChannelNameFromUserId(currentUser.userId, toUserId: userChat.userId)
        currentChannel.unsubscribe()
        currentChannel = LINPusherManager.sharedInstance.subscribeToPresenceChannelNamed(channelName, delegate: self)
        
        // Bind to event to receive data
        currentChannel.bindToEventNamed(kPusherEventNameNewMessage, handleWithBlock: { channelEvent in
            let replyData = channelEvent.getReplyData()
            let type = MessageType.fromRaw(replyData.type)
            
            let aMessage = LINMessage(incoming: true, sendDate: replyData.sendDate, content: replyData.text, type: type!)
            aMessage.state = MessageState.Sent
            
            self.addBubbleViewCellWithMessage(aMessage)
        })
    }
    
    private func generateUniqueChannelNameFromUserId(fromUserId: String, toUserId: String) -> String {
        var channelName = ""
        if fromUserId.compare(toUserId, options: NSStringCompareOptions.CaseInsensitiveSearch) == NSComparisonResult.OrderedAscending {
            channelName = "\(fromUserId)-\(toUserId)"
        } else {
            channelName = "\(toUserId)-\(fromUserId)"
        }
        
        return channelName
    }
    
    private func getMessageById(messageId: String) -> LINMessage? {
        for message in messageArray {
            if message.messageId == messageId {
                return message
            }
        }
        return nil
    }
    
    // KTODO: Refactor - Long method
    
    private func replyWithMessage(message: LINMessage) {
        if !LINNetworkHelper.isReachable() {
            updateMessageWithNewState(MessageState.UnSent, messageId: message.messageId!)
            return
        }
        
        self.conversationChanged = true
        let sendDate = NSDateFormatter.iSODateFormatter().stringFromDate(NSDate())
        
        var content: String?
        if message.type == MessageType.Text {
            content = message.content as? String
        } else {
            content = message.url
        }
        
        let replyDict = ["sender_id": currentUser.userId,
                         "message_type_id": message.type.toRaw(),
                         "content": content!,
                         "created_at": sendDate]
        
        if currentChatMode == LINChatMode.Online {
            currentChannel.triggerEventNamed(kPusherEventNameNewMessage,
                                             data: [kUserIdKey: currentUser.userId,
                                                   kFirstName: currentUser.firstName,
                                                   kAvatarURL: currentUser.avatarURL,
                                                   kMessageTextKey: content!,
                                                   kMessageSendDateKey: sendDate,
                                                   kMessageTypeKey: message.type.toRaw()
                                             ])
            
            repliesArray.append(replyDict)
            
            if repliesArray.count == 20 {
                postMessagesToServer()
            }
        } else {
            let tmpRepliesArray = [replyDict]
            
            LINNetworkClient.sharedInstance.creatBulkWithConversationId(conversationId, messagesArray: tmpRepliesArray) { (_) -> Void in }
            
            pushNotificationWithMessage(message)
        }
        
        // Check if message has sent or not
        if message.messageId != nil {
            if message.type == MessageType.Text {
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFireUpdateTextMessageHasSent:",
                    userInfo: message.messageId!, repeats: false)
            } else {
                updateMessageWithNewState(MessageState.Sent, messageId: message.messageId!)
            }
        }
        
        println("pusher] Count channel members: \(self.currentChannel.members.count)");
    }
    
    func timerFireUpdateTextMessageHasSent(timer: NSTimer) {
        let messageId = timer.userInfo as String
        updateMessageWithNewState(MessageState.Sent, messageId: messageId)
    }
    
    private func resendThisMessage(message: LINMessage) {
        if message.type == MessageType.Text || message.url != nil {
            replyWithMessage(message)
            return
        }
        
        if message.content == nil {
            self.updateMessageWithNewState(MessageState.UnSent, messageId: message.messageId!)
            return
        }
        
        var data: NSData?
        var fileType = LINFileType.Audio
        if message.type == MessageType.Photo {
            data = UIImageJPEGRepresentation(message.content as UIImage, 0.8)
            fileType = LINFileType.Image
        } else {
            data = message.content as? NSData
        }
        
        LINNetworkClient.sharedInstance.uploadFile(data!, fileType: fileType, completion: { (fileURL, error) -> Void in
            if let tmpFileURL = fileURL {
                message.url = fileURL
                self.replyWithMessage(message)
                return
            }
            
            self.updateMessageWithNewState(MessageState.UnSent, messageId: message.messageId!)
        })
    }
    
    // MARK: Load un-sent messages
    
    private func getListUnsentsChatWithMinSendDate(minSendDate: NSDate, maxSendDate: NSDate) -> [LINMessage] {
        var unsentsChatTemp = [LINMessage]()
        for message in unsentMessagesArray {
            let timeInterval = message.sendDate.timeIntervalSince1970
            
            if self.currentPageIndex == kChatHistoryBeginPageIndex {
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
    
    private func sortMessagesArrayAccordingToSendDate() {
        messageArray.sort{ $0.sendDate.timeIntervalSince1970 < $1.sendDate.timeIntervalSince1970 }
    }
    
    // MARK: Resend messages
    
    private func addToUnsentMessagesArrayWithMessage(message: LINMessage) {
        let index = getMessageInTempArrayWithMessageId(message.messageId)
        if index >= 0 {
            unsentMessagesArray.removeAtIndex(index)
        }
        
        unsentMessagesArray.append(message)
    }
    
    private func removeMessageFromUnsentMessagesArrayWithMessageId(messageId: String?) {
        let index = getMessageInTempArrayWithMessageId(messageId)
        if index >= 0 {
            unsentMessagesArray.removeAtIndex(index)
        }
    }
    
    private func getMessageInTempArrayWithMessageId(messageId: String?) -> Int {
        for (index, message) in enumerate(unsentMessagesArray) {
            if message.messageId == messageId {
                return index
            }
        }
        
        return -1
    }
    
    // MARK: Caching offline data
    
    func cachingChatHistoryData() {
        //Caching only first page (20 latest message)
        let lastestMessages = self.getLastestMessages()
        if lastestMessages != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let chatHistoryData = NSKeyedArchiver.archivedDataWithRootObject(lastestMessages!)
                LINResourceHelper.cachingChatHistoryData(self.conversationId, data: chatHistoryData)
            })
        }
    }
    
    func loadingCachedChatHistory() {
        let cachedData = LINResourceHelper.retrievingChatHistoryData(self.conversationId)
        if cachedData != nil {
            self.messageArray = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!) as [LINMessage]
            self.dataSource!.items = self.messageArray
            self.tableView.reloadData()
        }
    }
    
    func cachingUnsentChatData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let data = NSKeyedArchiver.archivedDataWithRootObject(self.unsentMessagesArray)
            LINResourceHelper.cachingUnsentChatData(self.conversationId, data: data)
        })
    }
    
    func loadCachedUnsentChatData() {
        let cachedData = LINResourceHelper.retrievingUnsentChatData(self.conversationId)
        if cachedData != nil {
            self.unsentMessagesArray = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!) as [LINMessage]
            println("You have \(self.unsentMessagesArray.count) un-sent messages.")
        }
    }
}

// MARK: LINBubbleCellDelegate

extension LINChatController: LINBubbleCellDelegate {
    
    func bubbleCellDidStartPlayingRecord(bubbleCell: LINBubbleCell) {
        if let indexPath = tableView.indexPathForCell(bubbleCell) {
            onPlayVoiceMessage = messageArray[indexPath.row]
            if let data = onPlayVoiceMessage!.content as? NSData {
                LINAudioHelper.sharedInstance.stopPlaying()
                LINAudioHelper.sharedInstance.playerDelegate = bubbleCell
                LINAudioHelper.sharedInstance.startPlaying(data)
            }
        }
    }
    
    func bubbleCellDidStopPlayingRecord(bubbleCell: LINBubbleCell) {
        onPlayVoiceMessage = nil
    }
    
    func bubbleCellDidStartResendMessage(bubbleCell: LINBubbleCell) {
        if let indexPath = tableView.indexPathForCell(bubbleCell) {
            // Move selected cell to bottom
            moveBubbleCellToBottomAtIndexPath(indexPath)
            
            // Try to resend this message
            resendThisMessage(messageArray.last!)
        }
    }
    
    func bubbleCellDidOpenPhotoPreview(bubbleCell: LINBubbleCell) {
        if let indexPath = tableView.indexPathForCell(bubbleCell) {
            let message = messageArray[indexPath.row]
            if let photo = message.content as? UIImage {
                let photoPreviewController = storyboard?.instantiateViewControllerWithIdentifier("kLINPhotoPreviewController") as LINPhotoPreviewController
                photoPreviewController.photo = photo
                photoPreviewController.downloaded = message.downloaded
                photoPreviewController.transitioningDelegate = self
                
                presentViewController(photoPreviewController, animated: true, completion: nil)
            }
        }
    }
}

//MARK: LINComposeBarViewDelegate

extension LINChatController: LINComposeBarViewDelegate {
    
    func composeBar(composeBar: LINComposeBarView, willChangeHeight newHeight: CGFloat) {
        composeBarHeightConstraint.constant = newHeight
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    func composeBar(composeBar: LINComposeBarView, sendMessage text: String) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: text, type: .Text)
        message.messageId = NSUUID.UUID().UUIDString
        addBubbleViewCellWithMessage(message)
        
        replyWithMessage(message)
    }
    
    func composeBar(composeBar: LINComposeBarView, willShowKeyBoard rect: CGRect, duration: NSTimeInterval) {
        moveComposeBarViewUpOrDown(true, rect: rect, duration: duration)
    }

    func composeBar(composeBar: LINComposeBarView, willHideKeyBoard rect: CGRect, duration: NSTimeInterval) {
        moveComposeBarViewUpOrDown(false, rect: rect, duration: duration)
    }
   
    func composeBar(composeBar: LINComposeBarView, startPickingMediaWithPickerViewController picker: UIImagePickerController) {
        presentViewController(picker, animated: true, completion: nil)
    }

    func composeBar(composeBar: LINComposeBarView, didPickPhoto photo: UIImage, messageId: String) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: photo, type: .Photo)
        message.messageId = messageId
        
        addBubbleViewCellWithMessage(message)
    }
        
    func composeBar(composeBar: LINComposeBarView, didUploadFile url: String, messageId: String) {
        let message = getMessageById(messageId)
        message?.url = url
        
        replyWithMessage(message!)
    }

    func composeBar(composeBar: LINComposeBarView, didFailToUploadFile error: NSError?, messageId: String) {
        updateMessageWithNewState(MessageState.UnSent, messageId: messageId)
    }
    
    func composeBar(composeBar: LINComposeBarView, didRecord data: NSData, messageId: String) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: data, type: .Voice)
        message.duration = LINAudioHelper.sharedInstance.getDurationFromData(data)
        message.messageId = messageId
        
        addBubbleViewCellWithMessage(message)
    }

    func composeBar(composeBar: LINComposeBarView, didFailToRecord error: NSError) {
        SVProgressHUD.showErrorWithStatus("\(error.localizedDescription) Please try again.")
    }

    private func moveComposeBarViewUpOrDown(isUp: Bool, rect: CGRect, duration: NSTimeInterval) {
        let keyboardHeight = rect.size.height
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.composeBarBottomLayoutGuideConstraint.constant = (isUp == false ? 0 : keyboardHeight)
        }) { (_) -> Void in
            if isUp {
                self.scrollBubbleTableViewToBottomAnimated(true)
            }
        }
    }
}

// MARK: PTPusherPresenceDelegate

extension LINChatController: PTPusherPresenceChannelDelegate {
    
    func presenceChannelDidSubscribe(channel: PTPusherPresenceChannel!) {
        println("[pusher] Channel members: \(channel.members)")
        if channel.members.count == 2 {
            currentChatMode = LINChatMode.Online
        }
    }
    
    func presenceChannel(channel: PTPusherPresenceChannel!, memberAdded member: PTPusherChannelMember!) {
        println("[pusher] Member joined channel: \(member)")
        currentChatMode = LINChatMode.Online
    }
    
    func presenceChannel(channel: PTPusherPresenceChannel!, memberRemoved member: PTPusherChannelMember!) {
        println("[pusher] Member left channel: \(member)")
        currentChatMode = LINChatMode.Offline
        
        postMessagesToServer()
    }
}

// MARK: LINPusherManagerDelegate

extension LINChatController: LINPusherManagerDelegate {
    
    func pusherManager(pusherManager: LINPusherManager, didFailToSubscribeToChannel channel: PTPusherChannel) {
        println("Auto re-subscribe to channel: \(channel.name)")
        subscribeToPresenceChannel()
    }
}

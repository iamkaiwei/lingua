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
let kLINChatHistoryBeginPageIndex = 1
let kLINChatHistoryMaxLenght = 20

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
    
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    private var onPlayVoiceMessage: LINMessage?
    private var conversationChanged = false
    
    var delegate: LINChatControllerDelegate?

    var conversation: LINConversation = LINConversation() {
        didSet {
            userChat = conversation.getChatUser()
            conversationId = conversation.conversationId
        }
    }
    
    var conversationId: String = "" {
        didSet {
            chatHistoryHelper.conversationId = conversationId
            unsentChatHelper.conversationId = conversationId
        }
    }
    
    var userChat = LINUser()
    private var currentUser = LINUser()
    private var currentPageIndex = kLINChatHistoryBeginPageIndex
    private var currentChatMode = LINChatMode.Offline
    
    // Helpers
    private var pusherChannel = LINPusherChannel()
    private var unsentChatHelper = LINUnsentChatHelper()
    private var chatHistoryHelper = LINChatHistoryHelper()
    
    // Layout contraints
    @IBOutlet weak var composeBarBottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeBarHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        composeBar.delegate = self
        LINPusherManager.sharedInstance.delegate = self
        
        configureUI()
        setupTableView()

        unsentChatHelper.loadCachedUnsentChatData()
        
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
            self.currentUser = tmpuser
            chatHistoryHelper.currentUserId = self.currentUser.userId
        }
        
        nameLabel.text = userChat.firstName
        likeButton.selected = conversation.isLiked
        flagButton.selected = conversation.isFlagged
    }

    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomActive", name: kLINNotificationAppDidBecomActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: kLINNotificationAppDidEnterBackground, object: nil)
        
        topNavigationView.registerForNetworkStatusNotification(lostConnection: kLINNotificationAppDidLostConnection, restoreConnection: kLINNotificationAppDidRestoreConnection)
        tableView.registerForNetworkStatusNotification(lossConnection: kLINNotificationAppDidLostConnection, restoreConnection: kLINNotificationAppDidRestoreConnection)
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
        
        dataSource = LINArrayDataSource(items: chatHistoryHelper.messagesArray, cellIdentifier: cellIdentifier, configureClosure: configureClosure)
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
            if error != nil {
                return
            }
            
            sender.selected = isOn
            if likeButtonTouched {
                self.conversation.isLiked = isOn
            } else {
                self.conversation.isFlagged = isOn
            }
        })
    }
    
    private func leaveConversation() {
        LINNetworkClient.sharedInstance.leaveConversationWithConversationId(conversationId, completion: { (success) -> Void in })
    }
    
    func appDidEnterBackground() {
        leaveConversation()
        pusherChannel.unsubscribe()
        chatHistoryHelper.postMessagesToServer()
        chatHistoryHelper.cachingChatHistoryData()
        unsentChatHelper.cachingUnsentChatData()
    }
    
    func appDidBecomActive() {
        subscribeToPresenceChannel()
        loadListLastestMessages()
        LINAudioHelper.sharedInstance.cancelRecording()
    }
    
    private func pushNotificationWithMessage(message: LINMessage) {
        let remoteNotificationHelper = LINRemoteNotificationHelper()
        remoteNotificationHelper.pushNotificationWithMessage(message, currentUser: self.currentUser,
                                                             partnerId: self.userChat.userId,
                                                             conversationId: self.conversationId)
    }
    
    private func addBubbleViewCellWithMessage(message: LINMessage) {
        chatHistoryHelper.messagesArray.append(message)
        dataSource!.items = chatHistoryHelper.messagesArray
        
        let indexPaths = [NSIndexPath(forRow: chatHistoryHelper.messagesArray.count - 1, inSection: 0)]
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    private func moveBubbleCellToBottomAtIndexPath(indexPath: NSIndexPath) {
        chatHistoryHelper.moveMessageToIndex(indexPath.row)
        dataSource!.items = chatHistoryHelper.messagesArray

        let toIndexPath = NSIndexPath(forRow: chatHistoryHelper.messagesArray.count - 1, inSection: 0)
        
        tableView.beginUpdates()
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: toIndexPath)
        tableView.endUpdates()
        
        tableView.reloadRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.None)
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    private func showStateSentForBubbleCell(#message: LINMessage) {
        if message.type == LINMessageType.Text {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "timerFireUpdateTextMessageHasSent:",
                userInfo: message.messageId!, repeats: false)
        } else {
            updateMessageWithNewState(LINMessageState.Sent, messageId: message.messageId!)
        }
    }
    
    private func updateMessageWithNewState(state: LINMessageState, messageId: String) {
        let messageTuple = chatHistoryHelper.getMessageById(messageId)
        if messageTuple != nil {
            let message = messageTuple!.message
            message.state = state
            
            let indexPaths = [NSIndexPath(forRow: messageTuple!.index, inSection: 0)]
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
            
            unsentChatHelper.addOrRemoveMessage(message: message)
        }
    }
    
    func timerFireUpdateTextMessageHasSent(timer: NSTimer) {
        let messageId = timer.userInfo as String
        updateMessageWithNewState(LINMessageState.Sent, messageId: messageId)
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
        return chatHistoryHelper.getHeightForCellAtIndex(indexPath.row)
    }
    
    private func loadListLastestMessages() {
        loadChatHistoryWithLenght(kLINChatHistoryMaxLenght, page: currentPageIndex)
    }
    
    private func loadChatHistoryWithLenght(lenght: Int, page: Int) {
        chatHistoryHelper.loadChatHistoryWithLenght(lenght, page: page) { (repliesArray) -> Void in
            if let tmpRepliesArray = repliesArray {
                // Get un-sents chat
                let dateFormatter = NSDateFormatter.iSODateFormatter()
                let maxSendDate = dateFormatter.dateFromString(tmpRepliesArray.first!.createdAt)
                let minSendDate = dateFormatter.dateFromString(tmpRepliesArray.last!.createdAt)
                let unsentsChatTemp = self.unsentChatHelper.getListUnsentsChat(minSendDate: minSendDate!,
                    maxSendDate: maxSendDate!,
                    currentPageIndex: self.currentPageIndex)
                
                // Mix unsents chat to chat history
                self.chatHistoryHelper.mixAnUnsentMessages(unsentsChatTemp)
                
                // Update data source and reload tableview
                self.dataSource!.items = self.chatHistoryHelper.messagesArray
                
                if self.currentPageIndex == kLINChatHistoryBeginPageIndex {
                    self.tableView.reloadData()
                    self.scrollBubbleTableViewToBottomAnimated(true)
                } else {
                    self.addListBubbleCellsWithCount(tmpRepliesArray.count)
                }
                
                self.currentPageIndex++
                
                if page == kLINChatHistoryBeginPageIndex {
                    self.chatHistoryHelper.cachingChatHistoryData()
                }
            }
            
            self.pullRefreshControl.endRefreshing()
        }
    }
    
    func loadOlderMessages() {
        loadChatHistoryWithLenght(kLINChatHistoryMaxLenght, page: currentPageIndex)
    }
    
    private func scrollBubbleTableViewToBottomAnimated(animated: Bool) {
        let lastRowIdx = chatHistoryHelper.messagesArray.count - 1
        if lastRowIdx >= 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIdx, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    private func subscribeToPresenceChannel() {
        pusherChannel.subcribe(fromUserId: currentUser.userId, toUserId: userChat.userId, delegate: self)
        pusherChannel.receivedMessage(completion: { (message) -> Void in
            self.addBubbleViewCellWithMessage(message)
        })
    }
    
    private func replyWithMessage(message: LINMessage) {
        if !LINNetworkHelper.isReachable() { // No connection
            updateMessageWithNewState(LINMessageState.UnSent, messageId: message.messageId!)
            return
        }
        
        self.conversationChanged = true
        let sendDate = NSDateFormatter.iSODateFormatter().stringFromDate(NSDate())
        let content: String? = message.type == LINMessageType.Text ? message.content as? String : message.url
        
        let replyDict = ["sender_id": currentUser.userId,
                         "message_type_id": message.type.rawValue,
                         "content": content!,
                         "created_at": sendDate]
        
        if currentChatMode == LINChatMode.Online {
            pusherChannel.sendMessage(currentUser: currentUser, text: content!, sendDate: sendDate, messageType: message.type)
            chatHistoryHelper.addNewReply(replyDict)
            chatHistoryHelper.shouldPostRepliesArrayToServer()
        } else {
            // Offline mode
            let tmpRepliesArray = [replyDict]
            LINNetworkClient.sharedInstance.creatBulkWithConversationId(conversationId, messagesArray: tmpRepliesArray) { (_) -> Void in }
            pushNotificationWithMessage(message)
        }
        
        showStateSentForBubbleCell(message: message)
    }
    
    private func resendThisMessage(message: LINMessage) {
        if message.type == LINMessageType.Text || message.url != nil {
            replyWithMessage(message)
            return
        }
        
        if message.content == nil {
            self.updateMessageWithNewState(LINMessageState.UnSent, messageId: message.messageId!)
            return
        }
        
        var data: NSData?
        var fileType = LINFileType.Audio
        if message.type == LINMessageType.Photo {
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
            
            // Upload failed
            self.updateMessageWithNewState(LINMessageState.UnSent, messageId: message.messageId!)
        })
    }
    
    // MARK: Caching offline data
    
    func loadingCachedChatHistory() {
        chatHistoryHelper.loadCachedChatHistory()
        self.dataSource!.items = chatHistoryHelper.messagesArray
     }
}

// MARK: LINBubbleCellDelegate

extension LINChatController: LINBubbleCellDelegate {
    
    func bubbleCellDidStartPlayingRecord(bubbleCell: LINBubbleCell) {
        if let indexPath = tableView.indexPathForCell(bubbleCell) {
            onPlayVoiceMessage = chatHistoryHelper.messagesArray[indexPath.row]
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
            resendThisMessage(chatHistoryHelper.messagesArray.last!)
        }
    }
    
    func bubbleCellDidOpenPhotoPreview(bubbleCell: LINBubbleCell) {
        if let indexPath = tableView.indexPathForCell(bubbleCell) {
            let message = chatHistoryHelper.messagesArray[indexPath.row]
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

// MARK: LINComposeBarViewDelegate

extension LINChatController: LINComposeBarViewDelegate {
    
    func composeBar(composeBar: LINComposeBarView, willChangeHeight newHeight: CGFloat) {
        composeBarHeightConstraint.constant = newHeight
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    func composeBar(composeBar: LINComposeBarView, sendMessage text: String) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: text, type: .Text)
        message.messageId = NSUUID().UUIDString
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
        let messageTuple = chatHistoryHelper.getMessageById(messageId)
        if messageTuple != nil {
            let message = messageTuple!.message
            message.url = url
            
            replyWithMessage(message)
        }
    }

    func composeBar(composeBar: LINComposeBarView, didFailToUploadFile error: NSError?, messageId: String) {
        updateMessageWithNewState(LINMessageState.UnSent, messageId: messageId)
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
        
        chatHistoryHelper.postMessagesToServer()
    }
}

// MARK: LINPusherManagerDelegate

extension LINChatController: LINPusherManagerDelegate {
    
    func pusherManager(pusherManager: LINPusherManager, didFailToSubscribeToChannel channel: PTPusherChannel) {
        println("Auto re-subscribe to channel: \(channel.name)")
        subscribeToPresenceChannel()
    }
}
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
    func shouldMoveConversationToTheTop(conversationId:String) -> Void
}

class LINChatController: UIViewController {
    @IBOutlet weak var composeBar: LINComposeBarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topNavigationView:LINTopNavigationView!
    @IBOutlet weak var likeButton:UIButton!
    @IBOutlet weak var flagButton:UIButton!
    
    private var pullRefreshControl: UIRefreshControl = UIRefreshControl()
    private var messageArray = [LINMessage]()
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    private var onPlayVoiceMessage: LINMessage?
    
    private var currentChannel = PTPusherPresenceChannel()
    private var conversationChanged : Bool = false
    var delegate:LINChatControllerDelegate?

    var conversation: LINConversation = LINConversation() {
        didSet {
            userChat = conversation.getChatUser()
            conversationId = conversation.conversationId
        }
    }
    var conversationId: String = ""
    
    private var currentUser = LINUser()
    var userChat = LINUser()
    private var repliesArray = [AnyObject]()
    private var currentPageIndex = kChatHistoryBeginPageIndex
    private var currentChatMode = LINChatMode.Offline

    // Layout contraints
    @IBOutlet weak var composeBarBottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeBarHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add loading view to load older messages
        pullRefreshControl.addTarget(self, action: Selector("loadOlderMessages"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(pullRefreshControl)
        composeBar.delegate = self
        
        configureTapGestureOnTableView()
        
        if let tmpuser = LINUserManager.sharedInstance.currentUser {
            currentUser = tmpuser
        }
        
        nameLabel.text = userChat.firstName
        likeButton.selected = conversation.isLiked
        flagButton.selected = conversation.isFlagged
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomActive", name: kNotificationAppDidBecomActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: kNotificationAppDidEnterBackground, object: nil)
        
        setupTableView()

        if LINNetworkHelper.isReachable() {
            loadListLastestMessages()
        }
        else {
            loadingCachedChatHistory()
        }
                
        self.topNavigationView.registerForNetworkStatusNotification(lostConnection: kNotificationAppDidLostConnection, restoreConnection: kNotificationAppDidRestoreConnection)
        self.tableView.registerForNetworkStatusNotification(lossConnection: kNotificationAppDidLostConnection, restoreConnection: kNotificationAppDidRestoreConnection)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.topNavigationView.checkingConnectionStatus()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subcribeToPresenceChannel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        leaveConversation()
        currentChannel.unsubscribe()
        postMessagesToServer()
        cachingChatHistoryData()

        //Call previous view controller to re-arrange the order
        if self.conversationChanged {
            if self.delegate != nil {
                self.delegate?.shouldMoveConversationToTheTop(conversationId)
            }
        }

        //Stop audio helper
        LINAudioHelper.sharedInstance.stopPlaying()
    }
}

extension LINChatController {
    // MARK: Configuration
    
    private func configureTapGestureOnTableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
        tableView.addGestureRecognizer(tapGesture)
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
}

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
}

extension LINChatController: LINComposeBarViewDelegate {
    //MARK: LINComposeBarViewDelegate

    func composeBar(composeBar: LINComposeBarView, willChangeHeight height: CGFloat) {
        composeBarHeightConstraint.constant += height
        scrollBubbleTableViewToBottomAnimated(true)
    }

    func composeBar(composeBar: LINComposeBarView, sendMessage text: String) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: text, type: .Text)
        addBubbleViewCellWithMessage(message)
        replyWithMessage(message)
    }
    
    func composeBar(composeBar: LINComposeBarView, willShowKeyBoard rect: CGRect, duration: NSTimeInterval) {
        if composeBarBottomLayoutGuideConstraint.constant == 0 {
            moveComposeBarViewUpOrDown(true, rect: rect, duration: duration)
            scrollBubbleTableViewToBottomAnimated(true)
        }
    }

    func composeBar(composeBar: LINComposeBarView, willHideKeyBoard rect: CGRect, duration: NSTimeInterval) {
        if composeBarBottomLayoutGuideConstraint.constant > 0 {
            moveComposeBarViewUpOrDown(false, rect: rect, duration: duration)
        }
    }
   
    func composeBar(composeBar: LINComposeBarView, startPickingMediaWithPickerViewController picker: UIImagePickerController) {
        presentViewController(picker, animated: true, completion: nil)
    }

    func composeBar(composeBar: LINComposeBarView, didPickPhoto photo: UIImage) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: photo, type: .Photo)
        addBubbleViewCellWithMessage(message)
    }
    
    func composeBar(composeBar: LINComposeBarView, didUploadPhoto imageURL: String) {
        let message  = LINMessage(incoming: false, sendDate: NSDate(), content: imageURL, type: .Photo)
        replyWithMessage(message)
    }

    func composeBar(composeBar: LINComposeBarView, didRecord data: NSData) {
        let message = LINMessage(incoming: false, sendDate: NSDate(), content: data, type: .Voice)
        message.duration = LINAudioHelper.sharedInstance.getDurationFromData(data)
        addBubbleViewCellWithMessage(message)
    }

    func composeBar(composeBar: LINComposeBarView, didFailToRecord error: NSError) {
        SVProgressHUD.showErrorWithStatus("\(error.localizedDescription) Please try again.")
    }

    func composeBar(composeBar: LINComposeBarView, didUploadRecord url: String) {
        let message  = LINMessage(incoming: false, sendDate: NSDate(), content: url, type: .Voice)
        replyWithMessage(message)
    }

    private func moveComposeBarViewUpOrDown(isUp: Bool, rect: CGRect, duration: NSTimeInterval) {
        let keyboardHeight = rect.size.height
        self.composeBarBottomLayoutGuideConstraint.constant = (isUp == false ? 0 : keyboardHeight)
       
        var composeBarFrame = composeBar.frame
        var tableFrame = tableView.frame
        let tmpHeight = (isUp == true ? -keyboardHeight : keyboardHeight)
        composeBarFrame.origin.y += tmpHeight
        tableFrame.size.height += tmpHeight
       
        UIView.animateWithDuration(duration, animations: {
            self.composeBar.frame = composeBarFrame
            self.tableView.frame = tableFrame
        })
    }

    private func replyWithMessage(message: LINMessage) {
        self.conversationChanged = true
        let sendDate = NSDateFormatter.iSODateFormatter().stringFromDate(NSDate())
        
        var content: String?
        if message.url != nil {
            content = message.url
        }
        else if message.content != nil {
            if let tempContent = message.content as? String {
                content = tempContent
            }
            else {
                return
            }
        }
        else {
            return //Nothing to send here...
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
            // KTODO: No internet --> Add this message to replies array
            LINNetworkClient.sharedInstance.creatBulkWithConversationId(conversationId, messagesArray: tmpRepliesArray) {
                (success) -> Void in
            }
            
            pushNotificationWithMessage(message)
        }
        
        println("pusher] Count channel members: \(self.currentChannel.members.count)");
    }
    
    @IBAction func backButtonTouched(sender: UIButton) {
        composeBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onFlagButton(sender:UIButton) {
        var actionType:LINActionType
        var isOn : Bool = !sender.selected
        if isOn {
            actionType = LINActionType.LINActionTypeFlag
        }
        else {
            actionType = LINActionType.LINActionTypeUnFlag
        }
        
        LINNetworkClient.sharedInstance.callActionAPI(actionType, userId:userChat.userId, {(error) -> Void in
            if error == nil {
               println("Action completed successfully")
               sender.selected = isOn
               self.conversation.isFlagged = isOn
            }
            else {
                println("Action got error : \(error?.localizedDescription)")
            }
        })
    }
    
    @IBAction func onLikeButton(sender:UIButton) {
        var actionType:LINActionType
        var isOn : Bool = !sender.selected
        if isOn {
            actionType = LINActionType.LINActionTypeLike
        }
        else {
            actionType = LINActionType.LINActionTypeUnLike
        }
        
        LINNetworkClient.sharedInstance.callActionAPI(actionType, userId:userChat.userId, {(error) -> Void in
            if error == nil {
               println("Action completed successfully")
               sender.selected = isOn
               self.conversation.isLiked = isOn
            }
            else {
                println("Action got error : \(error?.localizedDescription)")
            }
        })
    }
}

extension LINChatController {
    // MARK: Functions
    
    private func leaveConversation() {
        LINNetworkClient.sharedInstance.leaveConversationWithConversationId(conversationId,
            completion: { (success) -> Void in
        })
    }
    
    func appDidEnterBackground() {
        leaveConversation()
        currentChannel.unsubscribe()
        postMessagesToServer()
    }
    
    func appDidBecomActive() {
        subcribeToPresenceChannel()
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
        push.setData(["aps": ["alert": alertTitle, "sound": "defaut"],
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
        
        // KTODO: Check status of internet connection
        // If no internet --> return
        
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
        tableView.dataSource = dataSource
        
        let indexPaths = [NSIndexPath(forRow: messageArray.count - 1, inSection: 0)]
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    private func addListBubbleCellsWithCount(count: Int) {
        var contentOffset = self.tableView.contentOffset
        
        UIView.setAnimationsEnabled(false)
        
        var indexPaths = [NSIndexPath]()
        var heightForNewRows: CGFloat = 0
        
        for var i = 0; i < count; i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            indexPaths.append(indexPath)
            
            heightForNewRows += heightForCellAtIndexPath(indexPath)
        }
        
        contentOffset.y += heightForNewRows
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
        tableView.endUpdates()
        
        UIView.setAnimationsEnabled(true)
        
        // Keep uitableview static when inserting rows at the top
        self.tableView.setContentOffset(contentOffset, animated: false)
    }
    
    private func heightForCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        let message = messageArray[indexPath.row]

        switch(message.type) {
            case .Text:
                if message.height != 0 {
                    height = message.height
                } else {
                    height = (message.content! as String).sizeOfStringUseTextStorage().height
                }
                height += kTextCellHeightPadding
            case .Photo:
                var imageSize = CGSize()
                if let tmpPhoto = message.content as? UIImage {
                    imageSize = tmpPhoto.size.scaledSize()
                } else {
                    imageSize = CGSize.getSizeFromImageURL(message.url! as String).scaledSize()
                }
                height = imageSize.height + kPhotoCellHeightPadding
                case .Voice:
                    height = kVoiceMessageMaxHeight
            default:
               break
        }
        return height
    }

    private func loadListLastestMessages() {
        loadChatHistoryWithLenght(kChatHistoryMaxLenght, page: currentPageIndex)
    }
    
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
                        self.messageArray.insert(aMessage, atIndex: 0)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        if tmpRepliesArray.count > 0 {
                            self.dataSource!.items = self.messageArray
                            self.tableView.dataSource = self.dataSource
                            
                            if self.currentPageIndex == kChatHistoryBeginPageIndex {
                                self.tableView.reloadData()
                                self.scrollBubbleTableViewToBottomAnimated(true)
                            } else {
                                self.addListBubbleCellsWithCount(tmpRepliesArray.count)
                            }
                            self.currentPageIndex++
                            if page == 1 {
                                self.cachingChatHistoryData()
                            }
                        }
                        self.pullRefreshControl.endRefreshing()
                    }
                }
        }
    }

    func reloadChatTableContent() {
        self.dataSource!.items = self.messageArray
        self.tableView.dataSource = self.dataSource
        self.tableView.reloadData()
    }

    func getLastestMessages() -> [LINMessage]? {
        var numberOfMessage = min(self.messageArray.count,kChatHistoryMaxLenght)
        if numberOfMessage == 0 {
            return nil
        }
        var messageCount = self.messageArray.count
        var startIndex:Int = messageCount - messageCount
        var endIndex:Int = messageCount - 1
        var lastestMessages = Array(self.messageArray[startIndex...endIndex]) as [LINMessage]
        return lastestMessages
    }

    func cachingChatHistoryData() {
        //Caching only first page (20 latest message)
        var lastestMessages = self.getLastestMessages()
        if lastestMessages != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                var chatHistoryData = NSKeyedArchiver.archivedDataWithRootObject(lastestMessages!)
                LINResourceHelper.cachingChatHistoryData(self.conversationId, data: chatHistoryData)
            })
        }
    }
    
    func loadingCachedChatHistory() {
        let cachedData = LINResourceHelper.retrievingChatHistoryData(self.conversationId)
        if cachedData != nil {
            self.messageArray = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!) as [LINMessage]
            self.reloadChatTableContent()
        }
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
    
    private func subcribeToPresenceChannel() {
        let channelName = generateUniqueChannelNameFromUserId(currentUser.userId, toUserId: userChat.userId)
        currentChannel.unsubscribe()
        currentChannel = LINPusherManager.sharedInstance.subscribeToPresenceChannelNamed(channelName, delegate: self)
        
        // Bind to event to receive data
        currentChannel.bindToEventNamed(kPusherEventNameNewMessage, handleWithBlock: { channelEvent in
            println("Channel event data: \(channelEvent.data)")
            
            let replyData = channelEvent.getReplyData()
            let type = MessageType.fromRaw(replyData.type)
            var aMessage = LINMessage(incoming: true, sendDate: replyData.sendDate, content: replyData.text, type: type!)
            
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
}

extension LINChatController: UITableViewDelegate {
    // MARK: UITableviewDelegate
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return heightForCellAtIndexPath(indexPath)
    }
}

extension LINChatController: PTPusherPresenceChannelDelegate {
    // MARK: PTPusherPresenceDelegate
    
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

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
    @IBOutlet weak var composeBarBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    private var pullRefreshControl: UIRefreshControl = UIRefreshControl()
    private var messagesDataArray = [LINMessage]()
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    
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
    
    private var addButtonClicked:Bool = false
    private var shouldChangeInputTextViewFrame:Bool = true
    
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
        
        //nameLabel.text = userChat.firstName
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomActive", name: kNotificationAppDidBecomActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: kNotificationAppDidEnterBackground, object: nil)
        
        setupTableView()
        loadListLastestMessages()
                
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

        //Call previous view controller to re-arrange the order 
        if self.conversationChanged {
            if self.delegate != nil {
                self.delegate?.shouldMoveConversationToTheTop(conversationId)
            }
        }
    }
}

extension LINChatController {
    // MARK: Configuration
    
    private func configureTapGestureOnTableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        let configureClosure: TableViewCellConfigureClosure = { (bubbleCell: UITableViewCell, messageData: AnyObject) -> Void in
            (bubbleCell as LINBubbleCell).delegate = self
            (bubbleCell as LINBubbleCell).configureCellWithMessageData(messageData as LINMessage)
        }
        
        dataSource = LINArrayDataSource(items: messagesDataArray, cellIdentifier: cellIdentifier, configureClosure: configureClosure)
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0)
        tableView.registerClass(LINBubbleCell.self, forCellReuseIdentifier: cellIdentifier)
    }
}

extension LINChatController: LINBubbleCellDelegate {
    func bubbleCell(bubbleCell: LINBubbleCell, updatePhotoWithMessageData messageData: LINMessage) {
        let indexPath: NSIndexPath? = tableView.indexPathForRowAtPoint(bubbleCell.center)
        if indexPath != nil && messageData.photo != nil {
            println("Resize height for cell at row \(indexPath!.row)")
            messagesDataArray[indexPath!.row] = messageData
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
            tableView.endUpdates()
        }
    }
}

extension LINChatController: LINComposeBarViewDelegate {
    
    func composeBar(composeBar: LINComposeBarView, sendMessage message: String) {
        let messageData = LINMessage(incoming: false, text: "", sendDate: NSDate(), photo: nil, type: .Voice)
        addBubbleViewCellWithMessageData(messageData)
        replyWithText(message, type: .Text)
    }
    
    func composeBar(composeBar: LINComposeBarView, willShowKeyBoard rect: CGRect, duration: NSTimeInterval) {
        var composeBarFrame = composeBar.frame
        composeBarFrame.origin.y -= rect.size.height
        var tableFrame = tableView.frame
        tableFrame.size.height -= rect.size.height
        self.composeBarBottomLayoutGuideConstraint.constant = rect.size.height
        UIView.animateWithDuration(duration, animations: {
            self.composeBar.frame = composeBarFrame
            self.tableView.frame = tableFrame
            self.scrollBubbleTableViewToBottomAnimated(true)
        })
    }

    func composeBar(composeBar: LINComposeBarView, willHideKeyBoard rect: CGRect, duration: NSTimeInterval) {
        var composeBarFrame = composeBar.frame
        composeBarFrame.origin.y += rect.size.height
        var tableFrame = tableView.frame
        tableFrame.size.height += rect.size.height
        self.composeBarBottomLayoutGuideConstraint.constant = 0
        UIView.animateWithDuration(duration, animations: {
            self.composeBar.frame = composeBarFrame
            self.tableView.frame = tableFrame
        })
    }

    private func replyWithText(text: String, type: MessageType) {
        self.conversationChanged = true
        let sendDate = NSDateFormatter.iSODateFormatter().stringFromDate(NSDate())
        
        if type == MessageType.Text {
            let messageData = LINMessage(incoming: false, text: text, sendDate: NSDate(), photo: nil, type: type)
            addBubbleViewCellWithMessageData(messageData)
        }
        
        let replyDict = ["sender_id": currentUser.userId,
                         "message_type_id": type.toRaw(),
                         "content": text,
                         "created_at": sendDate]
        
        if currentChatMode == LINChatMode.Online {
            currentChannel.triggerEventNamed(kPusherEventNameNewMessage,
                data: [kUserIdKey: currentUser.userId,
                       kFirstName: currentUser.firstName,
                       kAvatarURL: currentUser.avatarURL,
                       kMessageTextKey: text,
                       kMessageSendDateKey: sendDate,
                       kMessageTypeKey: type.toRaw()
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
            
            pushNotificationWithMessage(text, sendDate: sendDate, type: type)
        }
        
        println("pusher] Count channel members: \(self.currentChannel.members.count)");
    }
    
    @IBAction func backButtonTouched(sender: UIButton) {
        composeBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnTableView(sender: UITapGestureRecognizer) {
        composeBar.hide()
    }

    func composeBar(composeBar: LINComposeBarView, startPickingMediaWithPickerViewController picker: UIImagePickerController) {
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func composeBar(composeBar: LINComposeBarView, replyWithPhoto photo: UIImage) {
        let messageData = LINMessage(incoming: false, text: "", sendDate: NSDate(), photo: photo, type: .Photo)
        addBubbleViewCellWithMessageData(messageData)
    }
    
    func composeBar(composeBar: LINComposeBarView, replyWithImageURL imageURL: String) {
        replyWithText(imageURL, type: .Photo)
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
    }
    
    private func pushNotificationWithMessage(text: String, sendDate: String, type: MessageType) {
        // Create our Installation query
        let pushQuery = PFInstallation.query()
        pushQuery.whereKey(kUserIdKey, equalTo: userChat.userId)
        
        var content = type.getSubtitleWithText(text)
        let alertTitle = "\(currentUser.firstName): \(content)"
        
        let push = PFPush()
        push.setData(["aps": ["alert": alertTitle, "sound": "defaut"],
                      kUserIdKey: currentUser.userId,
                      kFirstName: currentUser.firstName,
                      kAvatarURL: currentUser.avatarURL,
                      kMessageSendDateKey: sendDate,
                      kMessageTypeKey: type.toRaw(),
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
    
    private func addBubbleViewCellWithMessageData(messageData: LINMessage) {
        // Update data source
        messagesDataArray.append(messageData)
        dataSource!.items = messagesDataArray
        tableView.dataSource = dataSource
        
        let indexPaths = [NSIndexPath(forRow: messagesDataArray.count - 1, inSection: 0)]
        
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
        let messageData = messagesDataArray[indexPath.row]
        return LINBubbleCell.getHeighWithMessageData(messageData)
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
                        
                        let messageData = LINMessage(incoming: incoming,
                                                     text: reply.content,
                                                     sendDate: NSDateFormatter.iSODateFormatter().dateFromString(reply.createdAt)!,
                                                     photo: nil,
                                                     type: MessageType.fromRaw(reply.messageTypeId)!)
                        self.messagesDataArray.insert(messageData, atIndex: 0)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        if tmpRepliesArray.count > 0 {
                            self.dataSource!.items = self.messagesDataArray
                            self.tableView.dataSource = self.dataSource
                            
                            if self.currentPageIndex == kChatHistoryBeginPageIndex {
                                self.tableView.reloadData()
                                self.scrollBubbleTableViewToBottomAnimated(true)
                            } else {
                                self.addListBubbleCellsWithCount(tmpRepliesArray.count)
                            }
                            
                            self.currentPageIndex++
                        }
                        self.pullRefreshControl.endRefreshing()
                    }
                }
        }
        
    }
    
    func loadOlderMessages() {
        loadChatHistoryWithLenght(kChatHistoryMaxLenght, page: currentPageIndex)
    }
    
    private func scrollBubbleTableViewToBottomAnimated(animated: Bool) {
        let lastRowIdx = messagesDataArray.count - 1
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
            let messageData = LINMessage(incoming: true, text: replyData.text, sendDate: replyData.sendDate, photo: nil, type: type!)
            self.addBubbleViewCellWithMessageData(messageData)
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

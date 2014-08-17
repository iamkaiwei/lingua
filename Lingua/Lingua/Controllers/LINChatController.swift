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

class LINChatController: UIViewController, UITextViewDelegate, UITableViewDelegate {
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    private var pullRefreshControl: UIRefreshControl = UIRefreshControl()
    private var emoticonsView: LINEmoticonsView!
    
    @IBOutlet weak var inputContainerViewBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    private var messagesDataArray = [LINMessage]()
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    
    private var currentChannel = PTPusherPresenceChannel()
    
    var conversation: LINConversation = LINConversation() {
        didSet {
            userChat = conversation.getChatUser()
        }
    }
    
    private var currentUser = LINUser()
    var userChat = LINUser()
    private var repliesArray = [AnyObject]()
    private var currentPageIndex = kChatHistoryBeginPageIndex
    
    private var isChatScreenVisible: Bool = false
    private var addButtonClicked: Bool = false
    private var shouldChangeInputTextViewFrame: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add loading view to load older messages
        pullRefreshControl.addTarget(self, action: Selector("loadOlderMessages"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(pullRefreshControl)
        
        configureInputContainerView()
        configureTapGestureOnTableView()
        
        if let tmpuser = LINUserManager.sharedInstance.currentUser {
            currentUser = tmpuser
        }
        
        nameLabel.text = userChat.firstName
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadListLastestMessages", name: kNotificationAppDidBecomActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postMessagesToServer", name: kNotificationAppDidEnterBackground, object: nil)
        
        loadListLastestMessages()
        setupTableView()
        
        isChatScreenVisible = true
        
        // Emoticon view
        emoticonsView = NSBundle.mainBundle().loadNibNamed("LINEmoticonsView", owner: self, options: nil)[0] as LINEmoticonsView
        emoticonsView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
    
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        isChatScreenVisible = false
        
        postMessagesToServer()
    }
    
    // MARK: Configuration
    
    private func configureInputContainerView () {
        let backgroundView = UIImageView(image: UIImage(named: "bg_chat"))
        inputContainerView.addSubview(backgroundView)
        inputContainerView.sendSubviewToBack(backgroundView)
        
        inputTextView.clipsToBounds = true
        inputTextView.layer.cornerRadius = 10.0
    }
    
    private func configureTapGestureOnTableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        let configureClosure: TableViewCellConfigureClosure = { (bubbleCell: UITableViewCell, messageData: AnyObject) -> Void in
                (bubbleCell as LINBubbleCell).configureCellWithMessageData(messageData as LINMessage)
        }
        
        dataSource = LINArrayDataSource(items: messagesDataArray, cellIdentifier: cellIdentifier, configureClosure: configureClosure)
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0)
        tableView.registerClass(LINBubbleCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.reloadData()
        scrollBubbleTableViewToBottomAnimated(false)
    }
    
    // MARK: Actions
    
    @IBAction func buttonSendTouched(sender: UIButton) {
        if (inputTextView.text.utf16Count > 0) {
            replyWithText(inputTextView.text, type: .Text)
        }
    }
    
    func replyWithText(text: String, type: MessageType) {
        let sendDate = NSDateFormatter.iSODateFormatter().stringFromDate(NSDate())
        
        if currentChannel.members.count <= 1 {
            // Send push notification
            pushNotificationWithMessage(text, sendDate: sendDate, type: type)
        } else {
            // Trigger a client event
            currentChannel.triggerEventNamed(kPusherEventNameNewMessage,
                data: [kUserIdKey: currentUser.userId,
                       kFirstName: currentUser.firstName,
                       kAvatarURL: currentUser.avatarURL,
                       kMessageTextKey: text,
                       kMessageSendDateKey: sendDate,
                       kMessageTypeKey: type.toRaw()
                ])
        }
        
        if type == MessageType.Text {
            let messageData = LINMessage(incoming: false, text: text, sendDate: NSDate(), photo: nil, type: type)
            addBubbleViewCellWithMessageData(messageData)
        }
        
        repliesArray.append(["sender_id": currentUser.userId,
                             "message_type_id": type.toRaw(),
                             "content": text,
                             "created_at": sendDate])
        
        if repliesArray.count == 20 {
            postMessagesToServer()
        }

        inputTextView.text = ""
        textViewDidChange(inputTextView)
        
        println("pusher] Count channel members: \(self.currentChannel.members.count)");
    }
    
    @IBAction func backButtonTouched(sender: UIButton) {
        inputTextView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnTableView(sender: UITapGestureRecognizer) {
        if !emoticonsView.isHidden {
            hideEmoticonsView()
        }
        
        shouldChangeInputTextViewFrame = true
        inputTextView.resignFirstResponder()
    }
    
    @IBAction func buttonAddTouched(sender: UIButton) {
        if !addButtonClicked {
            if shouldChangeInputTextViewFrame {
                changeInputFrame()
            }
            
            // Show emoticons view
            showEmoticonsView()
        } else {
            // Hide emotions view
            hideEmoticonsView()
        }
    }
    
    // MARK: UITableView delegate
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return heightForCellAtIndexPath(indexPath)
    }

    // MARK: Functions 
    
    private func pushNotificationWithMessage(text: String, sendDate: String, type: MessageType) {
        // Create our Installation query
        let pushQuery = PFInstallation.query()
        pushQuery.whereKey(kUserIdKey, equalTo: userChat.userId)
        
        var content = type.getSubtitleWithText(text)
        let alertTitle = currentUser.firstName + ": " + content
        
        let push = PFPush()
        push.setData(["aps": ["alert": alertTitle, "sound": "defaut"],
                     kUserIdKey: currentUser.userId,
                     kFirstName: currentUser.firstName,
                     kAvatarURL: currentUser.avatarURL,
                     kMessageSendDateKey: sendDate,
                     kMessageTypeKey: type.toRaw()])
        push.setQuery(pushQuery)
        
        push.sendPushInBackgroundWithBlock({ (success, error) in
            if success {
                println("[parse] push notification successfully.")
            } else {
                println("[parse] push notification has some errors: \(error!.description)")
            }
        })
    }
    
    func postMessagesToServer() {
        if repliesArray.count <= 0 {
            return
        }
        
        // KTODO: Check status of internet connection
        // If no internet --> return
        
       LINNetworkClient.sharedInstance.creatBulkWithConversationId(conversation.conversationId,
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
    
    func loadListLastestMessages() {
        subcribeToPresenceChannel()
        
        loadChatHistoryWithLenght(kChatHistoryMaxLenght, page: currentPageIndex)
    }
    
    private func loadChatHistoryWithLenght(lenght: Int, page: Int) {
        LINNetworkClient.sharedInstance.getChatHistoryWithConversationId(conversation.conversationId,
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
                                                     sendDate: NSDateFormatter.iSODateFormatter().dateFromString(reply.createdAt),
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
    
    func subcribeToPresenceChannel() {
        currentChannel = LINPusherManager.sharedInstance.subcribeToChannelFromUserId(currentUser.userId, toUserId: userChat.userId)
        
        // Bind to event to receive data
        currentChannel.bindToEventNamed(kPusherEventNameNewMessage, handleWithBlock: { channelEvent in
            println("Channel event data: \(channelEvent.data)")
            
            let replyData = channelEvent.getReplyData()
            
            let type = MessageType.fromRaw(replyData.type)
            let messageData = LINMessage(incoming: true, text: replyData.text, sendDate: replyData.sendDate, photo: nil, type: type!)
            self.addBubbleViewCellWithMessageData(messageData)
            
            // If User is not in chat screen ---> Show banner to notify to user
            if !self.isChatScreenVisible {
                LINMessageHelper.showNotificationWitUserId(replyData.userId, name: replyData.firstName, text: replyData.text, avatarURL: replyData.avatarURL, type: replyData.type)
            }
        })
    }
    
    func showEmoticonsView() {
        addButtonClicked = true
        addButton.setImage(UIImage(named: "icn_cancel_blue"), forState: UIControlState.Normal)
        
        shouldChangeInputTextViewFrame = false
        inputTextView.resignFirstResponder()
        emoticonsView.showInViewController(self)
    }
    
    func hideEmoticonsView() {
        addButtonClicked = false
        addButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)

        inputTextView.becomeFirstResponder()
        emoticonsView.hide()
    }
    
    // MARK: Keyboard Events Notifications

    func handleKeyboardWillShowNotification(notification: NSNotification) {
        if !emoticonsView.isHidden {
            hideEmoticonsView()
        }
        
        if shouldChangeInputTextViewFrame {
            keyboardWillChangeFrameWithNotification(notification, showKeyboard: true)
            scrollBubbleTableViewToBottomAnimated(true)
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        if shouldChangeInputTextViewFrame {
           keyboardWillChangeFrameWithNotification(notification, showKeyboard: false)
        }
    }
    
    func keyboardWillChangeFrameWithNotification(notfication: NSNotification, showKeyboard: Bool) {
        let userInfo = notfication.userInfo
        let kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue().size
        var animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue

        if showKeyboard {
            // Convert the keyboard frame from screen to view coordinates.
            let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
            let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
            let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
            
            // The input container view should be adjusted, update the constant for this constraint.
            self.inputContainerViewBottomLayoutGuideConstraint.constant -= originDelta
        } else {
            self.inputContainerViewBottomLayoutGuideConstraint.constant = 0
        }
        
        view.setNeedsUpdateConstraints()
    
        UIView.animateWithDuration(animationDuration, animations: {
            var inputContainerFrame = self.inputContainerView.frame
            var tableFrame = self.tableView.frame
            
            if showKeyboard {
                inputContainerFrame.origin.y -= kbSize.height
                tableFrame.size.height -= kbSize.height
            } else {
                inputContainerFrame.origin.y += kbSize.height
                tableFrame.size.height += kbSize.height
            }
            
            self.inputContainerView.frame = inputContainerFrame
            self.tableView.frame = tableFrame
            
            self.view.layoutIfNeeded()
        })
    }
    
    func changeInputFrame() {
        shouldChangeInputTextViewFrame = false
        
        self.inputContainerViewBottomLayoutGuideConstraint.constant = emoticonsView.frame.size.height
        let kbSize = emoticonsView.frame.size
        
        UIView.animateWithDuration(0.3, animations: {
            var inputContainerFrame = self.inputContainerView.frame
            var tableFrame = self.tableView.frame
            
            inputContainerFrame.origin.y -= kbSize.height
            tableFrame.size.height -= kbSize.height

            self.inputContainerView.frame = inputContainerFrame
            self.tableView.frame = tableFrame
        })
    }
    
    
    // MARK: TextView Delegate
    
    func textViewDidChange(textView: UITextView!) {
        if  textView.text.utf16Count > 0 {
            sendButton.hidden = false
            speakButton.hidden = true
        } else {
            sendButton.hidden = true
            speakButton.hidden = false
        }
   }
}

extension LINChatController: LINEmoticonsViewDelegate {
    func emoticonsView(emoticonsView: LINEmoticonsView, startPickingMediaWithPickerViewController picker: UIImagePickerController) {
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, replyWithPhoto photo: UIImage) {
        let messageData = LINMessage(incoming: false, text: "", sendDate: NSDate(), photo: photo, type: .Photo)
        addBubbleViewCellWithMessageData(messageData)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, replyWithImageURL imageURL: String) {
        replyWithText(imageURL, type: .Photo)
    }
}

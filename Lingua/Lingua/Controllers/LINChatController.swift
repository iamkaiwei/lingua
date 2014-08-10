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

class LINChatController: UIViewController, UITextViewDelegate, UITableViewDelegate {
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var emoticonsView: LINEmoticonsView!
    
    
    @IBOutlet weak var inputContainerViewBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    private var messagesDataArray = [LINMessage]()
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    
    private var currentChannel = PTPusherPresenceChannel()
    private var currentUser = LINUser()
    var userChat = LINUser()
    
    private var isChatScreenVisible: Bool = false
    private var conversation: LINConversation?
    private var addButtonClicked: Bool = false
    private var shouldChangeInputTextViewFrame: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInputContainerView()
        configureTapGestureOnTableView()
        
        if let tmpuser = LINUserManager.sharedInstance.currentUser {
            currentUser = tmpuser
        }
        
        nameLabel.text = userChat.firstName
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadHistoryChatData", name: kNotificationAppBecomActive, object: nil)
        
        loadHistoryChatData()
        setupTableView()
        
        isChatScreenVisible = true
        
        // Emoticon view
        emoticonsView = NSBundle.mainBundle().loadNibNamed("LINEmoticonsView", owner: self, options: nil)[0] as LINEmoticonsView
        collectionView.registerClass(LINEmoticonCell.self, forCellWithReuseIdentifier: "EmoticonCellIdentifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
    
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        isChatScreenVisible = false
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
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0)
        tableView.registerClass(LINBubbleCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.reloadData()
        scrollBubbleTableViewToBottomAnimated(false)
    }
    
    // MARK: Actions
    
    @IBAction func buttonSendTouched(sender: UIButton) {
        if (inputTextView.text.utf16Count > 0) {
            let sendDate = NSDateFormatter.stringWithDefautFormatFromDate(NSDate())
            
            if currentChannel.members.count <= 1 {
                // Send push notification
                pushNotificationWithMessage(inputTextView.text, sendDate: sendDate)
            } else {
                // Trigger a client event
                currentChannel.triggerEventNamed(kPusherEventNameNewMessage,
                                                 data: [kUserIdKey: currentUser.userId,
                                                        kFirstName: currentUser.firstName,
                                                        kAvatarURL: currentUser.avatarURL,
                                                        kMessageTextKey: inputTextView.text,
                                                        kMessageSendDateKey: sendDate])
            }
            
            let messageData = LINMessage(incoming: false, text: inputTextView.text, sendDate: NSDate())
            addBubbleViewCellWithMessageData(messageData)
            
            // KTODO: Save chat history
            
            inputTextView.text = ""
            textViewDidChange(inputTextView)
            
            println("pusher] Count channel members: \(self.currentChannel.members.count)");
        }
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
    
    @IBAction func imagesButtonTouched(sender: UIButton) {
        println("Choose photo from albums")
    }
    
    @IBAction func photosButtonTouched(sender: UIButton) {
        println("Take a new photo")
    }
    
    // MARK: UITableView delegate
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let messageData = messagesDataArray[indexPath.row]
        return LINBubbleCell.getHeighWithMessageData(messageData)
    }
    
    // MARK: Functions 
    
    private func pushNotificationWithMessage(text: String, sendDate: String) {
        // Create our Installation query
        let pushQuery = PFInstallation.query()
        pushQuery.whereKey(kUserIdKey, equalTo: userChat.userId)
        
        let alertTitle = currentUser.firstName + ": " + text
        
        let push = PFPush()
        push.setData(["aps": ["alert": alertTitle, "sound": "defaut"],
                     kUserIdKey: currentUser.userId,
                     kFirstName: currentUser.firstName,
                     kAvatarURL: currentUser.avatarURL,
                     kMessageSendDateKey: sendDate])
        push.setQuery(pushQuery)
        
        push.sendPushInBackgroundWithBlock({ (success, error) in
            if success {
                println("[parse] push notification successfully.")
            } else {
                println("[parse] push notification has some errors: \(error!.description)")
            }
        })
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
    
    func loadHistoryChatData() {
        
        // Create new conversation
        LINNetworkClient.sharedInstance.createNewConversationWithTeacherId(currentUser.userId, learnerId: userChat.userId) {
           (conversation, error) -> Void in
            if let tmpConversation = conversation {
                self.conversation = tmpConversation
            }
         }
        
        subcribeToPresenceChannel()
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
            
            let messageData = LINMessage(incoming: true, text: replyData.text, sendDate: replyData.sendDate)
            self.addBubbleViewCellWithMessageData(messageData)
            
            // If User is not in chat screen ---> Show banner to notify to user
            if !self.isChatScreenVisible {
                LINMessageHelper.showNotificationWitUserId(replyData.userId, name: replyData.firstName, text: replyData.text, avatarURL: replyData.avatarURL)
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
    
    
    // MARK - TextView Delegate
    
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

extension LINChatController: UICollectionViewDataSource, UICollectionViewDelegate {
   
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoticonCellIdentifier", forIndexPath: indexPath) as LINEmoticonCell
        cell.imageView.image = UIImage(named: "emoticon_\(indexPath.row + 1)")
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        println("Emotion \(indexPath.row) is selected.")
    }
}


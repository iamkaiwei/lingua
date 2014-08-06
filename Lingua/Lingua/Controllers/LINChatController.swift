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
    
    @IBOutlet weak var inputContainerViewBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    private var messagesDataArray = [LINMessage]()
    private var dataSource: LINArrayDataSource?
    private let cellIdentifier = "kLINBubbleCell"
    
    private var currentChannel = PTPusherPresenceChannel()
    private var currentUser = LINUser()
    var userChat = LINUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInputContainerView()
        configureTapGestureOnTableView()
        
        if let tmpuser = LINUserManager.sharedInstance.currentUser {
            currentUser = tmpuser
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadHistoryChatData", name: kNotificationAppBecomActive, object: nil)
        
        loadHistoryChatData()
        setupTableView()
        
        AppDelegate.sharedDelegate().isChatScreenVisible = true
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
        AppDelegate.sharedDelegate().isChatScreenVisible = false
    }
    
    // MARK: Configuration
    
    private func configureInputContainerView () {
        inputContainerView.layer.borderColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0).CGColor
        inputContainerView.layer.borderWidth = 0.5
        
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
                                                 data: [kUserIdKey: userChat.userID,
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
        inputTextView.resignFirstResponder()
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
        pushQuery.whereKey(kUserIdKey, equalTo: userChat.userID)
        
        let alertTitle = currentUser.firstName + ": " + text
        
        let push = PFPush()
        push.setData(["aps": ["alert": alertTitle, "sound": "defaut"], kUserIdKey: currentUser.userID, kMessageSendDateKey: sendDate])
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
        subcribeToPresenceChannel()
    }
    
    private func scrollBubbleTableViewToBottomAnimated(animated: Bool) {
        let lastRowIdx = messagesDataArray.count - 1
        if lastRowIdx >= 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIdx, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }

    func subcribeToPresenceChannel() {
        currentChannel = LINPusherManager.sharedInstance.subcribeToChannelFromUserId(currentUser.userID, toUserId: userChat.userID)
        
        // Bind to event to receive data
        currentChannel.bindToEventNamed(kPusherEventNameNewMessage, handleWithBlock: { channelEvent in
            println("Channel event data: \(channelEvent.data)")
            
            let replyData = channelEvent.getReplyData()
            
            let messageData = LINMessage(incoming: true, text: replyData.text, sendDate: replyData.sendDate)
            self.addBubbleViewCellWithMessageData(messageData)
            
            // KTODO: If User is not in chat screen ---> Show banner to notify to user
            if !AppDelegate.sharedDelegate().isChatScreenVisible {
                UIAlertView(title: "Lingua", message: replyData.text, delegate: nil, cancelButtonTitle: "OK").show()
            }
        })
    }
    
    // MARK: Keyboard Events Notifications

    func handleKeyboardWillShowNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showKeyboard: true)
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showKeyboard: false)
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

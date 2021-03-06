//
//  LINFriendListController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINFriendListController: LINViewController, UITableViewDataSource, UITableViewDelegate, LINChatControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var arrFriends = [LINUser]()
    var newMessageCount:Int = 0
    var conversationList:[LINConversation] = [LINConversation](){
        didSet{
            newMessageCount = conversationList.filter({$0.haveNewMessage == true}).count
            updateNewMessageCount()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        
        //remove redundant row separator
        tableView.tableFooterView = UIView(frame:CGRectZero)
        
        loadCachedConversationData()
        
        //Register notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: kLINNotificationAppDidEnterBackground, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive", name: kLINNotificationAppDidBecomActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appReceivedNewMessage:", name: kLINNotificationAppReceivedNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidOpenChatViewFromHUD:", name: kLINNotificationAppDidOpenChatViewFromHUD, object: nil)
    }
    
    func updateNewMessageCount(){
        if self.newMessageCount < 0 {
            self.newMessageCount = 0
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLINNotificationShouldUpdateNewMessageCount, object: self.newMessageCount)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "kLINChatControllerIdentifier" {
            let indexPath: NSIndexPath? = tableView.indexPathForSelectedRow()!
            let chatController = segue.destinationViewController as LINChatController
            
            chatController.delegate = self
            chatController.conversation = self.conversationList[indexPath!.row]
            chatController.transitioningDelegate = self
        }
    }
    
    // MARK: LINChatControllerDelegate
    
    func chatControllerShouldMoveConversationToTheTop(conversationId:String) {
        moveConversationToTop(conversationId,markAsNewMessage:false)
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationList.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("kConversationCellIdentifier") as LINConversationCell
    
        let conversation = conversationList[indexPath.row]
        cell.configureWithConversation(conversation)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var conversation = self.conversationList[indexPath.row] as LINConversation
        if(conversation.haveNewMessage){
            conversation.haveNewMessage = false
            self.newMessageCount--
            updateNewMessageCount();
            
            //Unhightlight cell
            var selectedCell:LINConversationCell = tableView.cellForRowAtIndexPath(indexPath) as LINConversationCell
            selectedCell.updateHighlightedCell(false)
        }
    }
    
    // MARK: Local Notification
    func appDidOpenChatViewFromHUD(notification:NSNotification) {
        var conversationId:String = notification.object as String
        var index = self.indexForConnversationWithID(conversationId)
        if index >= 0 {
            var conversationToUpdate = self.conversationList[index]
            markConversation(conversationToUpdate, isRead: true)
            self.tableView.reloadData()
        }
    }

    func appDidEnterBackground() {
        cachingConversationData()
        //Set the badge number on the app icon
        UIApplication.sharedApplication().applicationIconBadgeNumber = self.newMessageCount
    }
    
    func appDidBecomeActive() {
        refreshConversationList()
    }
    
    func appReceivedNewMessage(notification:NSNotification) {
       var conversationId:String = notification.object as String
        moveConversationToTop(conversationId,markAsNewMessage:true)
    }
    
    func moveConversationToTop(conversationId:String , markAsNewMessage:Bool) {
        var index = self.indexForConnversationWithID(conversationId)
        if index >= 0 {
            var conversationToUpdate = self.conversationList[index]
            if markAsNewMessage {
                markConversation(conversationToUpdate, isRead: false)
            }
            conversationToUpdate.lastestUpdate = NSDateFormatter.iSODateFormatter().stringFromDate(NSDate())
            //Sorting conversation list here
            self.conversationList.removeAtIndex(index)
            self.conversationList.insert(conversationToUpdate, atIndex: 0)
            self.tableView.reloadData()
        }
    }
    
    func markConversation(conversation:LINConversation , isRead:Bool) {
        //Only if the conversation has new message and we want to mask it as read
        if conversation.haveNewMessage && isRead {
            conversation.haveNewMessage = false
            self.newMessageCount--
        }
        
        //If the conversation has no message and we want to mask it as contain new message
        if !conversation.haveNewMessage && !isRead {
            conversation.haveNewMessage = true
            self.newMessageCount++
        }
        
        self.updateNewMessageCount()
    }
    
    // MARK: Helpers
    func loadAllConversation() {
        LINNetworkClient.sharedInstance.getAllConversations { (conversationsArray, error) -> Void in
            if conversationsArray != nil {
                self.conversationList = conversationsArray!
                self.tableView.reloadData()
                //Caching in sub-thread
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    self.cachingConversationData()
                })
            }
        }
    }
    
    func refreshConversationList() {
        if LINNetworkHelper.isReachable(){
            //Network available , request new data from server
            loadAllConversation()
        }
        else{
            //Network Unavailable , load cached data
            NSLog("Network unavailable , loading cached data")
            loadCachedConversationData()
        }
    }
    
    func cachingConversationData() {
        var conversationData = NSKeyedArchiver.archivedDataWithRootObject(self.conversationList)
        LINResourceHelper.cachingConversationOfflineData(conversationData)
    }
    
    func loadCachedConversationData() {
        let cachedData = LINResourceHelper.retrievingCachedConversation()
        if cachedData != nil {
            self.conversationList = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!) as [LINConversation]
            self.tableView.reloadData()
        }
    }
    
    func getConversationWithID(conversationId:String) -> LINConversation? {
        var filteredList = self.conversationList.filter({$0.conversationId == conversationId}) as [LINConversation]
        if filteredList.count > 0 {
            return filteredList[0]
        }
        return nil
    }
    
    func indexForConnversationWithID(conversationId:String) -> Int {
        for (index, element) in enumerate(self.conversationList) {
            if element.conversationId == conversationId {
                return index
            }
        }
        return -1;
    }
}


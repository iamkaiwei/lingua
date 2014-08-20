//
//  LINFriendListController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINFriendListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
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
        refreshConversationList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: kNotificationAppDidEnterBackground, object: nil)
    }
    
    func appDidEnterBackground(){
        self.cachingConversationData()
    }
    
    func updateNewMessageCount(){
        if self.newMessageCount < 0 {
            self.newMessageCount = 0
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationShouldUpdateNewMessageCount, object: self.newMessageCount)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "kLINChatControllerIdentifier" {
            let indexPath: NSIndexPath = tableView.indexPathForSelectedRow()
            let chatController = segue.destinationViewController as LINChatController
            
            var conversation = self.conversationList[indexPath.row] as LINConversation
            if(conversation.haveNewMessage){
                conversation.haveNewMessage = false
                self.newMessageCount--
                updateNewMessageCount()
            }
            chatController.conversation = self.conversationList[indexPath.row]
            chatController.transitioningDelegate = self
            
        }
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return conversationList.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("kConversationCellIdentifier") as LINConversationCell
    
        let conversation = conversationList[indexPath.row]
        cell.configureWithConversation(conversation)
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        performSegueWithIdentifier("kLINChatControllerIdentifier", sender: self)
    }
    
    // MARK: Helpers
    
    func loadAllConversation() {
        LINNetworkClient.sharedInstance.getAllConversations { (conversationsArray, error) -> Void in
            if conversationsArray != nil {
                self.conversationList = conversationsArray!
                self.tableView.reloadData()
                self.cachingConversationData()
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
        self.conversationList = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData) as [LINConversation]
        self.tableView.reloadData()
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return LINPopPresentAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return LINShrinkDismissAnimationController()
    }
}


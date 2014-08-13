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
    var conversationList = [LINConversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        
        //loadAllFriends()
        loadAllConversation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "kLINChatControllerIdentifier" {
            let indexPath: NSIndexPath = tableView.indexPathForSelectedRow()
            let chatController = segue.destinationViewController as LINChatController
            
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
        cell.configureCellWithUserData(conversation)
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        performSegueWithIdentifier("kLINChatControllerIdentifier", sender: self)
    }
    
    // MARK: Helpers
    
    func loadAllFriends() {
        LINNetworkClient.sharedInstance.getAllUsers( {(arrUsers: [LINUser]?) -> Void in
            println("Load friends successfully.")
            
            var currentUser = LINUserManager.sharedInstance.currentUser
            self.arrFriends  = arrUsers!
            if currentUser != nil {
                for i in 0..<self.arrFriends.count {
                    let user = self.arrFriends[i]
                    if user.userId == currentUser!.userId {
                        self.arrFriends.removeAtIndex(i)
                        break
                    }
                }
            }
            
            self.tableView.reloadData()
        }, failture: {(error: NSError?) -> Void in
            if let err = error {
                println("Load all friends has some errors: \(err.description)")
            }
        })
    }
    
    func loadAllConversation(){
        
        LINNetworkClient.sharedInstance.getAllConversation({ (conversationsArray, error) -> Void in
            if conversationsArray != nil {
                self.conversationList = conversationsArray!
                for i in 0..<self.conversationList.count {
                    let conversation = self.conversationList[i]
                    println(conversation.conversationId)
                }
                self.tableView.reloadData()
            }
            }, failure: { (error:NSError?) -> Void in
            if let err = error {
                println("Loading conversation erorr : \(error?.description)")
            }
        })
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return LINPopPresentAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return LINShrinkDismissAnimationController()
    }
}


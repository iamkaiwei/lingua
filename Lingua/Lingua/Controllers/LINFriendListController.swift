//
//  LINFriendListController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINFriendListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var arrFriends = [LINUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        
        loadAllFriends()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "kLINChatControllerIdentifier" {
            let indexPath: NSIndexPath = tableView.indexPathForSelectedRow()
            let user = arrFriends[indexPath.row]
            
            let chatController = segue.destinationViewController as LINChatController
            chatController.userChat = user
        }
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return arrFriends.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("kFriendCellIdentifier") as LINFriendCell
        
        let user = arrFriends[indexPath.row]
        cell.configureCellWithUserData(user)
        
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
            if currentUser {
                for i in 0..<self.arrFriends.count {
                    let user = self.arrFriends[i]
                    if user.userID == currentUser!.userID {
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
}


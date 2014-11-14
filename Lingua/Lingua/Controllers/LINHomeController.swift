//
//  LINHomeController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINHomeController: LINViewController {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var teachButton: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var topNavigationView:LINTopNavigationView!
    
    var timer: NSTimer?
    var animationImages = [UIImage]()
    var selectedIndexQuote: UInt32 = 0
    let (quotes, authors) = LINResourceHelper.quotes()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0...49 {
            animationImages.append(UIImage(named: "loading_elip_\(i)")!)
        }
        selectedIndexQuote = arc4random_uniform(UInt32(quotes.count))
        tipLabel.text = self.quotes[Int(selectedIndexQuote)]
        authorLabel.text = self.authors[Int(selectedIndexQuote)]
        loadingImageView.animationImages = animationImages
        teachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startMatching"))
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "changeQuote", userInfo: nil, repeats: true)
        
        self.topNavigationView.registerForNetworkStatusNotification(lostConnection: kLINNotificationAppDidLostConnection, restoreConnection: kLINNotificationAppDidRestoreConnection)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewMessageCount:", name: kLINNotificationShouldUpdateNewMessageCount, object: nil)
        
        configureBadgeViewAppearance()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.topNavigationView.checkingConnectionStatus()
    }
    
    func configureBadgeViewAppearance(){
        messageButton.badgeView.badgeColor = UIColor.messageBadgeColor()
        messageButton.badgeView.position = MGBadgePosition.TopLeft
        messageButton.badgeView.outlineWidth = 0
        messageButton.badgeView.maximumBadgeValueAllowed = 99
    }
    
    func updateNewMessageCount(notification:NSNotification) {
        var messageCount:Int = notification.object as Int
        messageButton.badgeView.badgeValue = messageCount
        messageButton.badgeView.updateBadgeViewPosition()
    }
    
    func changeQuote() {
        var index = arc4random_uniform(UInt32(quotes.count))
        
        //To avoid repeated quotes in a row.
        if index == selectedIndexQuote {
            if index + 1 >= UInt32(quotes.count) {
                index = 0
            }
        }
        selectedIndexQuote = index
        
        UIView.animateWithDuration(1, animations: {
            self.tipLabel.alpha = 0
            self.authorLabel.alpha = 0
            }, completion: { _ in
                self.tipLabel.text = self.quotes[Int(index)]
                self.authorLabel.text = self.authors[Int(index)]
                UIView.animateWithDuration(1, animations: {
                    self.tipLabel.alpha = 1
                    self.authorLabel.alpha = 1
                })
            }
        )
    }
    
    @IBAction func openDrawer(sender: UIButton) {
        switch sender {
        case profileButton: mm_drawerController?.openDrawerSide(.Left, animated: true, completion: nil)
        case messageButton: mm_drawerController?.openDrawerSide(.Right, animated: true, completion: nil)
        default: break
        }
    }
    
    func startMatching() {
        if loadingImageView.isAnimating() { return }
        
        loadingImageView.startAnimating()
        LINNetworkClient.sharedInstance.matchUser(.Learner, { (arrUsers: [LINUser]) -> Void in
            self.loadingImageView.stopAnimating()
            if arrUsers.count <= 0 {
                return
            }
            
            let aUser = arrUsers[0] as LINUser
            LINStorageHelper.setObject(aUser.point--, forKey: kLINMatchingThreshold)
            LINNetworkClient.sharedInstance.createNewConversationWithTeacherId(aUser.userId,
                learnerId: LINUserManager.sharedInstance.currentUser!.userId,
                success: {
                    self.startChatViewController($0)
                },
                failure: { println($0) } )
            
        }, failture: { _ in
            self.loadingImageView.stopAnimating()
        })
    }
    
    func startChatViewController(conversation: LINConversation) {
        let chatVC = storyboard!.instantiateViewControllerWithIdentifier("kLINChatController") as LINChatController
        chatVC.conversation = conversation
        chatVC.transitioningDelegate = self
        presentViewController(chatVC, animated: true, completion: nil)
    }
    
    // MARK: Utility methods
    
    func openChatScreenWithUserId(userId: String, name: String, conversationId: String) {
        dismissViewControllerAnimated(false, completion: nil)
        
        // Show chat screen
        let chatController = storyboard?.instantiateViewControllerWithIdentifier("kLINChatController") as LINChatController
        let user = LINUser(userId: userId, firstName: name)
        chatController.userChat = user
        chatController.conversationId = conversationId
        chatController.transitioningDelegate = self
        presentViewController(chatController, animated: true, completion: nil)
    }
}

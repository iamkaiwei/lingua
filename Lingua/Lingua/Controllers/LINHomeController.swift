//
//  LINHomeController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINHomeController: LINViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var teachButton: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var timer: NSTimer?
    var animationImages = [UIImage]()
    var selectedIndexQuote: UInt32 = 0
    let (quotes, authors) = LINResourceHelper.quotes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...49 {
            animationImages.append(UIImage(named: "loading_elip_\(i)"))
        }
        selectedIndexQuote = arc4random_uniform(UInt32(quotes.count))
        tipLabel.text = self.quotes[Int(selectedIndexQuote)]
        authorLabel.text = self.authors[Int(selectedIndexQuote)]
        loadingImageView.animationImages = animationImages
        teachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startMatching"))
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "changeQuote", userInfo: nil, repeats: true)
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
        LINNetworkClient.sharedInstance.matchUser({ (arrUsers: [LINUser]) -> Void in
            self.loadingImageView.stopAnimating()
            if arrUsers.count <= 0 {
                return
            }
            
            let aUser = arrUsers[0] as LINUser
            LINNetworkClient.sharedInstance.createNewConversationWithTeacherId(aUser.userId,
                learnerId: LINUserManager.sharedInstance.currentUser!.userId,
                success: {
//                    self.startChatViewController($0)
                },
                failure: { println($0) } )
            
        }, failture: { _ in
            self.loadingImageView.stopAnimating()
        })
    }
    
    func startChatViewController(conversation: LINConversation) {
        let chatVC = storyboard.instantiateViewControllerWithIdentifier("kLINChatController") as LINChatController
        chatVC.conversation = conversation
        chatVC.transitioningDelegate = self
        presentViewController(chatVC, animated: true, completion: nil)
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return LINPopPresentAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return LINShrinkDismissAnimationController()
    }
}

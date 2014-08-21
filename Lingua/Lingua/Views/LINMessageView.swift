//
//  LINMessageView.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINMessageView: UIView {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    private var userId: String?
    private var conversationId: String?
    private var timer: NSTimer?
    
    @IBAction func closeButtonTouched(sender: UIButton) {
        hideNotification()
    }
}

extension LINMessageView {
    func hideNotification() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        
        timer?.invalidate()
        timer = nil
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {
            var frame = self.frame
            frame.origin.y -= self.frame.size.height
            self.frame = frame
            }, completion: { finished in
                self.removeFromSuperview()
        })
    }
    
    func showNotification() {
        let window = AppDelegate.sharedDelegate().window
        window!.addSubview(self)
        
        var frame = self.frame
        frame.origin.y -= self.frame.size.height
        self.frame = frame
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {
            var frame = self.frame
            frame.origin.y = 0
            self.frame = frame
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            }, completion: { finished in
        })
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("hideNotification"), userInfo: nil, repeats: false)
    }
}

extension LINMessageView {
    func configureWithUserId(userId: String, name: String, text: String, avatarURL: String, type: Int, conversationId: String) {
        self.userId = userId
        self.conversationId = conversationId
        nameLabel.text = name
        
        let messageType = MessageType.fromRaw(type)
        textLabel.text = messageType?.getSubtitleWithText(text)
        
        avatarImageView.sd_setImageWithURL(NSURL(string: avatarURL),
            placeholderImage: UIImage(named: "avatar_holder"))
        avatarImageView.addRoundedCorner()
        
        // Add gesture
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("openChatScreenWithGesture:"))
        addGestureRecognizer(gestureRecognizer)
    }
    
    func openChatScreenWithGesture(recognizer: UITapGestureRecognizer) {
        hideNotification()
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAppDidOpenChatViewFromHUD, object: conversationId!)
        LINNotificationHelper.openChatScreenWithUserId(userId!, name: nameLabel.text, conversationId: conversationId!)
    }
}
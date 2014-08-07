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
    
    private var timer: NSTimer?
    
    @IBAction func closeButtonTouched(sender: UIButton) {
        hideNotification()
    }
    
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
    
    func configureWithName(name: String, text: String, avatarURL: String) {
        nameLabel.text = name
        textLabel.text = text
        avatarImageView.sd_setImageWithURL(NSURL(string: avatarURL),
                                           placeholderImage: UIImage(named: "avatar_holder"))
        avatarImageView.addRoundedCorner()
    }
}
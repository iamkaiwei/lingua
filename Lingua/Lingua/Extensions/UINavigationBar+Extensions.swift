//
//  UINavigationBar+NetworkHelper.swift
//  Lingua
//
//  Created by TaiVuong on 8/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

let HUD_VIEW_TAG = 9999
let animationDuration = 0.5

extension UINavigationBar {
    
    func registerForNetworkStatusNotification(#lossConnection:String , restoreConnection:String) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidLostConnection", name: lossConnection, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidRestoreConnection", name: restoreConnection, object: nil)
    }
    
    func appDidLostConnection(notification:NSNotification) {
        let showingHUD = (self.viewWithTag(HUD_VIEW_TAG) != nil)
        if !showingHUD {
            var notificationView = self.getLossNotificationHUDView()
            notificationView.alpha = 0
            notificationView.frame = self.getRectForHUD(false)
            self.addSubview(notificationView)
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                notificationView.alpha = 1
                notificationView.frame = self.getRectForHUD(true)
            })
        }
    }
    
    func appDidRestoreConnection(notification:NSNotification) {
        var notificationView:UILabel = self.viewWithTag(HUD_VIEW_TAG) as UILabel
        if notificationView == nil {
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                notificationView.frame = self.getRectForHUD(false)
            }, completion: {(finished:Bool) -> Void in
                notificationView.removeFromSuperview()
            })
        }
    }
    
    func getLossNotificationHUDView() -> UIView {
        var notificationLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        notificationLabel.text = "Network was lost"
        notificationLabel.backgroundColor = UIColor.redColor()
        notificationLabel.textColor = UIColor.whiteColor()
        return notificationLabel;
    }
    
    func getRectForHUD(visible:Bool) -> CGRect {
        if visible {
            return CGRectMake(0, CGRectGetHeight(self.frame), 320, 30)
        }
        else {
            return CGRectMake(0, 0, 320, 30)
        }
    }
}
//
//  LINTopNavigationView.swift
//  Lingua
//
//  Created by TaiVuong on 8/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation


let HUD_VIEW_TAG = 9999
let animationDuration = 0.5

class LINTopNavigationView : UIView {
    
    func registerForNetworkStatusNotification(#lostConnection:String , restoreConnection:String) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidLostConnection", name: lostConnection, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidRestoreConnection", name: restoreConnection, object: nil)
    }
    func appDidLostConnection() {
        showLostConnectionHUDView()
    }
    
    func appDidRestoreConnection() {
        hideLostConnectionHUDView()
    }
    
    func showLostConnectionHUDView() {
        let showingHUD = (self.viewWithTag(HUD_VIEW_TAG) != nil)
        if !showingHUD {
            dispatch_async(dispatch_get_main_queue(), {
                var notificationView = self.getLostNotificationHUDView()
                notificationView.alpha = 0
                notificationView.frame = self.getRectForHUD(false)
                self.addSubview(notificationView)
                self.sendSubviewToBack(notificationView)
                
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    notificationView.alpha = 1
                    notificationView.frame = self.getRectForHUD(true)
                })
            })
        }

    }
    
    func hideLostConnectionHUDView(){
        var notificationView:UILabel? = self.viewWithTag(HUD_VIEW_TAG) as? UILabel
        if notificationView != nil {
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    notificationView!.frame = self.getRectForHUD(false)
                    }, completion: {(finished:Bool) -> Void in
                        notificationView!.removeFromSuperview()
                })
            })
        }
    }
    
    func checkingConnectionStatus() {
        if LINNetworkHelper.isReachable() {
            hideLostConnectionHUDView()
        }
        else{
            showLostConnectionHUDView()
        }
    }
    
    //Helper method
    func getLostNotificationHUDView() -> UILabel {
        var notificationLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        notificationLabel.text = "No Internet Connection"
        notificationLabel.backgroundColor = UIColor.networkStatusHUDColor()
        notificationLabel.textColor = UIColor.whiteColor()
        notificationLabel.textAlignment = NSTextAlignment.Center
        notificationLabel.font = UIFont(name: "System", size: 13)
        notificationLabel.tag = HUD_VIEW_TAG
        return notificationLabel;
    }
    
    func getRectForHUD(visible:Bool) -> CGRect {
        if visible {
            return CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 30)
        }
        else {
            return CGRectMake(0, 0, CGRectGetWidth(self.frame), 30)
        }
    }
}
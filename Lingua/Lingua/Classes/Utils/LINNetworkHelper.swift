//
//  LINNetworkHelper.swift
//  Lingua
//
//  Created by TaiVuong on 8/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINNetworkHelper : NSObject{

    enum LINNetworkNotificationType{
        case NetworkStatusOnline
        case NetworkStatusOffline
    }
    
    var reachability:Reachability

    class var sharedInstance:LINNetworkHelper{
    struct Static {
        static let sharedInstance:LINNetworkHelper = LINNetworkHelper()
        }
        return Static.sharedInstance
    }
    
    override init(){
        self.reachability = Reachability.reachabilityForInternetConnection() as Reachability
        
        self.reachability.unreachableBlock = {(reachability:Reachability!) -> Void in
            LINNetworkHelper.showNotificationWithType(LINNetworkNotificationType.NetworkStatusOffline)
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAppDidLostInternetConnection, object: nil)
        }
        
        self.reachability.reachableBlock = {(reachability:Reachability!) -> Void in
            LINNetworkHelper.showNotificationWithType(LINNetworkNotificationType.NetworkStatusOnline)
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAppDidRestoreConnection, object: nil)
        }
        self.reachability.startNotifier()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    
    //Class function
    class func isReachable() -> Bool {
        return LINNetworkHelper.sharedInstance.reachability.isReachable()
    }
    
    class func setupWithDefaultViewController(defaultViewController:UIViewController){
        TSMessage.setDefaultViewController(defaultViewController)
        var instance:LINNetworkHelper = LINNetworkHelper.sharedInstance
    }
    
    class func showNotificationWithType(type:LINNetworkNotificationType){
        var message:String? = nil
        var messageType:TSMessageNotificationType
        
        switch type {
        case LINNetworkNotificationType.NetworkStatusOffline :
            message = "Network offline"
            messageType = TSMessageNotificationType.Error
            break;
        case LINNetworkNotificationType.NetworkStatusOnline:
            message = "Network online"
            messageType = TSMessageNotificationType.Success
            break;
        default:
            break;
        }
        dispatch_async(dispatch_get_main_queue(), {
            TSMessage.showNotificationWithTitle(message, type: messageType)
        })
    }
}

//
//  LINNetworkHelper.swift
//  Lingua
//
//  Created by TaiVuong on 8/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINNetworkHelper {
    var reachability:Reachability
    
    class var sharedInstance:LINNetworkHelper{
    struct Static {
        static let sharedInstance:LINNetworkHelper = LINNetworkHelper()
        }
        return Static.sharedInstance
    }
    
    required init(){
        self.reachability = Reachability.reachabilityForInternetConnection() as Reachability
    }
    
    func canSendMessage() -> Bool{
        return self.reachability.isReachable()
    }
} 

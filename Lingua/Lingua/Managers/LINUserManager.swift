//
//  LINUserManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINUserManager {
    var currentUser = LINUser()
    
    class var sharedInstance : LINUserManager {
        struct Static {
            static let instance: LINUserManager = LINUserManager()
        }
        return Static.instance;
    }

    func getAccessToken() -> NSString {
        return currentUser.access_token
    }
    
    func isLoggedIn() -> Bool {
        return false
    }
}

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
            static let instance : LINUserManager = LINUserManager()
        }
        return Static.instance;
    }

    func getAccessToken() -> NSString {
        return PFUser.currentUser().sessionToken
    }
    
    func loginWithFacebookOnSuccess(success: ((user: PFUser?) -> Void), failture: ((error: NSError?) -> Void)) {
        PFFacebookUtils.logInWithPermissions(NSArray.facebookPermissionArray(), {
            (user: PFUser!, error: NSError!) -> Void in
            if !user {
                failture(error: error)
            } else  {
                success(user: user);
            }
        })
    }
    
    // Check If User is cached and wheather user's account linked to facebook
    func checkLogin() -> Bool {
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
             return true
        }
        return false
    }
}

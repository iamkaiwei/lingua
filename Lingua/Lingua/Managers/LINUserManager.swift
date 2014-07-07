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
        get {
            struct Static {
                static let instance : LINUserManager = LINUserManager()
            }
            return Static.instance;
        }
    }

    func getAccessToken() -> NSString {
        return PFUser.currentUser().sessionToken
    }
    
    func loginWithFacebookOnSuccess(success: ((user: PFUser!) -> Void), failture: ((error: NSError!) -> Void)) {
        PFFacebookUtils.logInWithPermissions(NSArray.facebookPermissionArray(), {
            (user: PFUser!, error: NSError!) -> Void in
            if !user {
                failture(error: error)
            } else  {
                success(user: user);
            }
        })
    }
}

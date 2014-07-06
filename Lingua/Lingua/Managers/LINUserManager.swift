//
//  LINUserManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINUserManager {
    let currentUser : LINUser = LINUser()
    
    class var sharedInstance : LINUserManager {
        get {
            struct Static {
                static let instance : LINUserManager = LINUserManager()
            }
            return Static.instance;
        }
    }

    func getAccessToken() -> NSString {
        return self.currentUser.access_token
    }
    
    func loginWithFacebookOnSuccess(success: ((user: PFUser!) -> Void), failture: ((error: NSError!) -> Void)) {
        PFFacebookUtils.logInWithPermissions(NSArray.facebookPermissionArray(), {
            (user: PFUser!, error: NSError!) -> Void in
            if !user {
                println("Uh oh. The user cancelled the Facebook login.")
                failture(error: error)
            } else  {
                self.updateWithCurrentUser(user)
                success(user: user);
            }
        })
    }
    
    func updateWithCurrentUser(user: PFUser) {
        // TODOME: Update to current user
    }
}

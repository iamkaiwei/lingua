//
//  LINUserManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINUserManager {
    var currentUser: LINUser?
    
    class var sharedInstance : LINUserManager {
        struct Static {
            static let instance: LINUserManager = LINUserManager()
        }
        return Static.instance;
    }
    
    init() {
        currentUser = LINStorageHelper.objectForKey(kLINCurrentUserKey) as? LINUser
    }
    
    func isLoggedIn() -> Bool {
        let serverToken = LINStorageHelper.objectForKey(kLINAccessTokenKey) as? LINAccessToken
        if serverToken == nil {
            return false
        }
        return serverToken!.isTokenValid() // KTODO: Calc exprire date
    }
    
    func loginWithFacebookToken(facebookToken: String?, completion: (success: Bool) -> Void){
        if facebookToken == nil {
            completion(success: false)
            return
        }
        
        LINNetworkClient.sharedInstance.getServerTokenWithFacebookToken(facebookToken!, completion: {
        (success: Bool) -> Void in
            completion(success: success)
            
            // Request user profile
            if success {
                LINNetworkClient.sharedInstance.getCurrentUser( { (user: LINUser?) -> Void in
                        if let tmpUser = user {
                            self.currentUser = tmpUser
                            
                            // Check device token
                            if tmpUser.deviceToken.utf16Count == 0 {
                                let deviceToken = LINStorageHelper.getStringValueForKey(kDeviceTokenKey)
                                if let tmpToken = deviceToken {
                                    self.currentUser!.deviceToken = tmpToken
                                    LINNetworkClient.sharedInstance.updateDeviceTokenWithUserId(self.currentUser!.userId, deviceToken: tmpToken)
                                }
                            }
                            
                            // Save user_id to parse
                            let currentInstallation = PFInstallation.currentInstallation()
                            if currentInstallation != nil {
                                currentInstallation.setObject(self.currentUser!.userId, forKey: kUserIdKey)
                                currentInstallation.saveInBackground()
                            }
                            
                            LINStorageHelper.setObject(self.currentUser!, forKey: kLINCurrentUserKey)
                        }
                    }
                    , failture: {(error: NSError?) -> Void in
                        println("Get current user has some errors: \(error?.description)")
                    })
            }
        })
    }
}

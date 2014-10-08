//
//  LINFacebookManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/25/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

protocol LINFacebookManagerDelegate {
    func facebookLoginSuccessed(facebookManager: LINFacebookManager)
    func facebookLoginFailed(facebookManager: LINFacebookManager)
}

class LINFacebookManager: NSObject {
    var delegate: LINFacebookManagerDelegate?
    var facebookToken: String? {
    if FBSession.activeSession() == nil {
        return nil
        }
        return FBSession.activeSession().accessTokenData.accessToken
    }
    
    class var sharedInstance: LINFacebookManager {
        struct Static {
           static let instance: LINFacebookManager = LINFacebookManager()
        }
        return Static.instance
    }
    
    func isOpenSession() -> Bool {
        if FBSession.activeSession() == nil {
            return false
        }
        return FBSession.activeSession().isOpen
    }
    
    func openSessionWithAllowLoginUI(allowLoginUI: Bool) {
        let readPermissions = ["public_profile", "email", "user_birthday", "user_location"]
        
        FBSession.openActiveSessionWithReadPermissions(readPermissions,
                                                       allowLoginUI: allowLoginUI,
                                                       completionHandler: { (session, state, error) -> Void in
            self.sessionStateChanged(session, state: state, error: error)
        })
    }
    
    func logout() {
        if  FBSession.activeSession() == nil {
            return
        }
        FBSession.activeSession().closeAndClearTokenInformation()
        LINStorageHelper.setObject("", forKey: kLINAccessTokenKey)
    }
    
    func sessionStateChanged(session: FBSession, state: FBSessionState, error: NSError?) {
        switch(state) {
        case FBSessionState.Open:
            delegate?.facebookLoginSuccessed(self)
        case FBSessionState.Closed, FBSessionState.ClosedLoginFailed:
            FBSession.activeSession().closeAndClearTokenInformation()
            if error != nil {
                delegate?.facebookLoginFailed(self)
            }
        default:
            break
        }
    }
}
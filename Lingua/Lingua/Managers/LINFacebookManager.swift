//
//  LINFacebookManager.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/25/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

protocol LINFacebookManagerDelegate {
    func facebookSessionStateChanged(facebookManager: LINFacebookManager)
    func facebookLoginSuccessed(facebookManager: LINFacebookManager)
    func facebookLoginFailed(facebookManager: LINFacebookManager)
}

class LINFacebookManager {
    let facebookToken: String = ""
    var delegate: LINFacebookManagerDelegate?
    
    class var sharedInstance: LINFacebookManager {
        struct Static {
            static let instance: LINFacebookManager = LINFacebookManager()
        }
        return Static.instance
    }
    
    func isOpenSession() -> Bool {
        return FBSession.activeSession().isOpen
    }
    
    func openSession() {
        let readPermissions = ["public_profile", "user_birthday", "user_location"]
        
        FBSession.openActiveSessionWithReadPermissions(readPermissions, allowLoginUI: true, {
            (session: FBSession?, state: FBSessionState?, error: NSError?) -> Void in
            self.sessionStateChanged(session!, state: state!, error: error!)
        })
    }
    
    func sessionStateChanged(session: FBSession, state: FBSessionState, error: NSError) {
        switch(state) {
            case FBSessionState.Open:
                delegate?.facebookLoginSuccessed(self)
                break
           case FBSessionState.Closed, FBSessionState.ClosedLoginFailed:
                FBSession.activeSession().closeAndClearTokenInformation()
                delegate?.facebookLoginFailed(self)
                break
            default:
                break
        }
        
        delegate?.facebookSessionStateChanged(self)
    }
}
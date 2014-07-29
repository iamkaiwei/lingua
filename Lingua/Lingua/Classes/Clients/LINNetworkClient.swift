//
//  LINNetworkClient.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/27/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

typealias CompletionClosure = (success: Bool, errorMessage: String) -> Void

// Requests
let kLINBaseURL = "http://linguatheapp.herokuapp.com/"
let kLINAPIPath = "api/v1/"
let kLINGetAccessTokenPath = "oauth/token"
let kLINGetCurrentUserPath = "users/me"
let kLINGetAllUsersPath = "users"

// Storage
let kLINAccessTokenKey = "kLINAccessTokenKey"
let kLINCurrentUserKey = "kLINCurrentUserKey"

class LINNetworkClient: OVCHTTPSessionManager {
    class var sharedInstance: LINNetworkClient {
    struct Static {
        static let instance: LINNetworkClient = LINNetworkClient()
        }
        return Static.instance
    }
    
    // MARK: Initialization
    
    init() {
        super.init(baseURL: NSURL(string: kLINBaseURL))
    }
    
    init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    init(baseURL url: NSURL!, managedObjectContext context: NSManagedObjectContext!, sessionConfiguration configuration: NSURLSessionConfiguration!)  {
        super.init(baseURL: url, managedObjectContext: context, sessionConfiguration: configuration)
    }
    
    // MARK: Shared
    
    func setAuthorizedRequest() {
        let accessToken = LINStorageHelper.objectForKey(kLINAccessTokenKey) as? LINAccessToken
        if accessToken != nil {
            println("Bearer \(accessToken!.accessToken)")
            let requestSerializer = self.requestSerializer
            requestSerializer.setValue("Bearer \(accessToken!.accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
    
    // MARK: Oauth token
    
    func getServerTokenWithFacebookToken(facebookToken: String,
                                         completion: (success: Bool) -> Void) {
        let parameters = ["client_id": "lingua-ios",
                          "client_secret": "l1n9u4",
                          "grant_type": "password",
                          "facebook_token": facebookToken]
        
        self.POST(kLINGetAccessTokenPath, parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                completion(success: false)
            } else {
                let serverToken = (response as OVCResponse).result as? LINAccessToken
                if serverToken != nil {
                    println(serverToken)
                    println("Access token: \(serverToken!.accessToken)")
                    LINStorageHelper.setObject(serverToken!, forKey: kLINAccessTokenKey)
                    completion(success: true)
                } else {
                    completion(success: false)
                }
            }
        })
    }
    
    func refreshTokenWithRefreshToken(refreshToken: String,
                                      completion: (success: Bool) -> Void ) {
        let parameters = ["client_id": "lingua-ios",
                          "client_secret": "l1n9u4",
                          "grant_type": "password",
                          "refresh_token": refreshToken]
        
        self.POST(kLINGetAccessTokenPath, parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                completion(success: false)
            } else {
                let serverToken = (response as OVCResponse).result as? LINAccessToken
                if serverToken != nil {
                    println("Access token: \(serverToken!.accessToken)")
                    LINStorageHelper.setObject(serverToken!, forKey: kLINAccessTokenKey)
                    completion(success: true)
                } else {
                    completion(success: false)
                }
            }
        })
    }
    
    func isValidToken(completion: (success: Bool) -> Void) {
        setAuthorizedRequest()
        
        self.GET(kLINAPIPath + kLINGetCurrentUserPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Token is not valid.")
                completion(success: false)
            } else {
                println("Token is valid.")
                completion(success: true)
            }
        })
    }
    
    // MARK: Users
    
    func getCurrentUser(success: (user: LINUser?) -> Void,
                        failture: (error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        self.GET(kLINAPIPath + kLINGetCurrentUserPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                failture(error: error!)
            } else {
                let user = (response as OVCResponse).result as? LINUser
                if user != nil {
                    println("Current user: \(user!.firstName)")
                    LINStorageHelper.setObject(user!, forKey: kLINCurrentUserKey)
                    success(user: user)
                } else {
                    failture(error: nil)
                }
            }
        })
    }
    
    func getAllUsers(success: (arrUsers: [LINUser]?) -> Void,
                    failture: (error: NSError?) -> Void) {
        setAuthorizedRequest()
                        
        self.GET(kLINAPIPath + kLINGetAllUsersPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                 failture(error: error!)
            } else {
                let arrUsers = (response as OVCResponse).result as? [LINUser]
                if let tmp = arrUsers {
                    success(arrUsers: tmp)
                } else {
                    failture(error: nil)
                }
            }
        })
    }
    
    // MARK: OVCHTTPSessionManager
    
    override class func modelClassesByResourcePath() -> [NSObject : AnyObject]! {
        return [kLINGetAccessTokenPath.bridgeToObjectiveC() : LINAccessToken.self,
               (kLINAPIPath + kLINGetCurrentUserPath).bridgeToObjectiveC() : LINUser.self,
               (kLINAPIPath + kLINGetAllUsersPath).bridgeToObjectiveC() : LINUser.self
        ]
    }
}
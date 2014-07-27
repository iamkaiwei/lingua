//
//  LINNetworkClient.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/27/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

typealias CompletionClosure = (success: Bool, errorMessage: String) -> Void

class LINNetworkClient: OVCHTTPSessionManager {
    
    let kBaseURL = "http://linguatheapp.herokuapp.com/"
    
    class var sharedInstance: LINNetworkClient {
    struct Static {
        static let instance: LINNetworkClient = LINNetworkClient()
        }
        return Static.instance
    }
    
    init() {
        super.init(baseURL: NSURL(string: kBaseURL))
    }
    
    init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    init(baseURL url: NSURL!, managedObjectContext context: NSManagedObjectContext!, sessionConfiguration configuration: NSURLSessionConfiguration!)  {
        super.init(baseURL: url, managedObjectContext: context, sessionConfiguration: configuration)
    }
    
    // MARK: Requests
    
    func getServerTokenWithFacebookToken(facebookToken: String) {
        let parameters = ["client_id": "lingua-ios",
                          "client_secret": "l1n9u4",
                          "grant_type": "password",
                          "facebook_token": facebookToken]
        
        self.POST("oauth/token", parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
            let accessToken = (response as OVCResponse).result as LINAccessToken
            
            println("\(accessToken.accessToken)")
        })
    }
    
    // MARK: OVCHTTPSessionManager
    
    override class func modelClassesByResourcePath() -> [NSObject : AnyObject]! {
        return ["oauth/token".bridgeToObjectiveC() : LINAccessToken.self]
    }
}
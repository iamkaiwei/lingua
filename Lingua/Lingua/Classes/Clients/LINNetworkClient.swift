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
let kLINGetAccessTokenPath = "oauth/token"
let kLINGetCurrentUserPath = "api/v1/users/me"
let kLINUsersPath = "api/v1/users"
let kLINSendNotification = "api/v1/users/send_notification"
let kLINMatchUser = "api/v1/users/match"
let kLINConversationsPath = "api/v1/conversations"
let kLINLanguagePath = "api/v1/languages"
let kLINUploadPath = "api/v1/upload"

// Storage
let kLINAccessTokenKey = "kLINAccessTokenKey"
let kLINCurrentUserKey = "kLINCurrentUserKey"
let kLINLastOnlineKey  = "kLINLastOnlineKey"

class LINNetworkClient: OVCHTTPSessionManager {
    class var sharedInstance: LINNetworkClient {
    struct Static {
        static let instance: LINNetworkClient = LINNetworkClient()
        }
        return Static.instance
    }
    
    // MARK: Initialization
    
    override init() {
        super.init(baseURL: NSURL(string: kLINBaseURL))
    }
    
    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    override init(baseURL url: NSURL!, managedObjectContext context: NSManagedObjectContext!, sessionConfiguration configuration: NSURLSessionConfiguration!)  {
        super.init(baseURL: url, managedObjectContext: context, sessionConfiguration: configuration)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
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
        
        self.GET(kLINGetCurrentUserPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
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
        
        self.GET(kLINGetCurrentUserPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                failture(error: error!)
            } else {
                let user = (response as OVCResponse).result as? LINUser
                if user != nil {
                    println("Current user: \(user!.firstName)")
                    success(user: user)
                } else {
                    failture(error: nil)
                }
            }
        })
    }
    
    func updateCurrentUser(success: () -> Void,
                           failture: (error: NSError?) -> Void) {
        setAuthorizedRequest()
            
        var parameters = [String: AnyObject]()
        var path = kLINUsersPath
        if let currentUser = LINUserManager.sharedInstance.currentUser {
            path = "\(path)/\(currentUser.userId)"
            parameters = ["learn_language_id": currentUser.learningLanguage!.languageID,
                          "native_language_id": currentUser.nativeLanguage!.languageID,
                          "spoken_proficiency_id": currentUser.speakingProficiency!.proficiencyID,
                          "written_proficiency_id": currentUser.writingProficiency!.proficiencyID,
                          "introduction" : currentUser.introduction]
        }
        else {
            return
        }
        
        self.PUT(path, parameters: parameters, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                failture(error: error)
                return
            }
            println(response?.result)
            success()
        })
    }
    
    func getAllUsers(success: (arrUsers: [LINUser]?) -> Void,
                    failture: (error: NSError?) -> Void) {
        setAuthorizedRequest()
                        
        self.GET(kLINUsersPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
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

    func sendNotificationWithUserId(userId: String, text: String, sendDate: String) {
        setAuthorizedRequest()
        
        let parameters = [kUserIdKey: userId,
                          "message": text,
                          "time_created": sendDate]
        
        self.POST(kLINSendNotification, parameters: parameters, completion: nil)
    }
    
    func updateDeviceTokenWithUserId(userId: String, deviceToken: String) {
        setAuthorizedRequest()
        
        let parameters = [kUserIdKey: userId,
                          kDeviceTokenKey: deviceToken]
        let path = "\(kLINUsersPath)/\(userId)"
                                        
        self.PUT(path, parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Update device token has some errors: \(error!.description)")
            } else {
                println("Update device token successfully.")
            }
        })
    }
    
    func matchUser(success: (arrUsers: [LINUser]) -> Void, failture: (error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        self.GET(kLINMatchUser, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                failture(error: error)
                return
            }
            println("Match users: \(response)")
            if let arrUsers = (response as OVCResponse).result as? [LINUser] {
                success(arrUsers: arrUsers)
                return
            }
            
            failture(error: nil)
        })
    }
    
    // MARK: Conversations
    
    func createNewConversationWithTeacherId(teacherId: String,
                                            learnerId: String,
                                              success: (conversation: LINConversation) -> Void,
                                              failure: (error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        let parameters = ["teacher_id": teacherId,
                          "learner_id": learnerId]
        
        self.POST(kLINConversationsPath, parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Create new conversation has some errors: \(error!.description)")
                failure(error: error)
                return
            }
            
            if let tmpConversation = (response as OVCResponse).result as? LINConversation {
                println("Current conversation: \(tmpConversation)")
                success(conversation: tmpConversation)
            }
        })
    }
    
    func getAllConversations(completion:(conversationsArray: [LINConversation]? , error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        self.GET(kLINConversationsPath, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Get all conversations has some errors: \(error!.description)")
                completion(conversationsArray: nil, error: error)
                return
            }
            
            if let tmpConversationArray = (response as OVCResponse).result as? [LINConversation] {
                println("All conversation \(tmpConversationArray)")
                completion(conversationsArray: tmpConversationArray, error: nil)
            }
        })
    }
    
    // MARK: Photos, Voices
    
    func uploadImage(image: UIImage,
                     completion: (imageURL: String?, error: NSError?) -> Void) {
        let imageData = UIImageJPEGRepresentation(image, 0.8) as NSData
        let fileName = "\(NSDate().timeIntervalSince1970)" + ".jpg"
                       
        self.POST(kLINUploadPath, parameters: nil, constructingBodyWithBlock: { (formData) -> Void in
            formData.appendPartWithFileData(imageData, name: "image", fileName: fileName, mimeType: "image/jpeg")
        }) { (response, error) -> Void in
                if error != nil {
                    println("Upload image has some errors: \(error!.description)")
                    completion(imageURL: nil, error: error!)
                    return
                }
                
                if let tmpImage = (response as OVCResponse).result as? LINPhoto {
                    println("Image URL: \(tmpImage.imageURL)")
                    completion(imageURL: tmpImage.imageURL, error: nil)
                }
        }
    }
    
    // MARK: OVCHTTPSessionManager
    
    override class func modelClassesByResourcePath() -> [NSObject : AnyObject]! {
        return [kLINGetAccessTokenPath: LINAccessToken.self,
                kLINGetCurrentUserPath: LINUser.self,
                kLINUsersPath: LINUser.self,
                kLINMatchUser: LINUser.self,
                kLINLanguagePath: LINLanguage.self,
                kLINConversationsPath: LINConversation.self,
                kLINUploadPath: LINPhoto.self
        ]
    }
}
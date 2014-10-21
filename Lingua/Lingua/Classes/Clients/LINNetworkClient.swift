//
//  LINNetworkClient.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/27/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

// Requests
let kLINBaseURL = "http://linguatheapp.herokuapp.com"
let kLINAPIPath = "/api/v1"
let kLINGetAccessTokenPath = "/oauth/token"
let kLINGetCurrentUserPath = "/users/me"
let kLINUsersPath = "/users"
let kLINSendNotification = "/users/send_notification"
let kLINMatchUser = "/users/match"
let kLINConversationsPath = "/conversations"
let kLINLanguagePath = "/languages"
let kLINUploadPath = "/upload"
let kLINMessagesPath = "/conversations/*/messages"
let kLINLeaveConversationPath = "/conversations/*/leave_conversation"
let kLINSetFlagPath = "/users/*/flag"
let kLINUnsetFlagPath = "/users/*/unflag"
let kLINLikePath = "/users/*/like"
let kLINUnlikePath = "/users/*/unlike"

// Storage
let kLINAccessTokenKey = "kLINAccessTokenKey"
let kLINCurrentUserKey = "kLINCurrentUserKey"
let kLINLastOnlineKey  = "kLINLastOnlineKey"

enum LINActionType {
    case LINActionTypeFlag
    case LINActionTypeUnFlag
    case LINActionTypeLike
    case LINActionTypeUnLike
}

enum LINPartnerRole {
    case Teacher
    case Learner
    case Fallback
    
    func stringFromRole() -> String {
        switch self {
        case Teacher: return "teacher"
        case Learner: return "learner"
        default: return "fallback"
        }
    }
}

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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: OVCHTTPSessionManager
    
    // TODOME: Expression was too complex
//    override class func modelClassesByResourcePath() -> [NSObject : AnyObject]! {
//        return [kLINGetAccessTokenPath: LINAccessToken.self,
//                "\(kLINAPIPath)" + "\(kLINGetCurrentUserPath)": LINUser.self,
//                "\(kLINAPIPath)" + "\(kLINUsersPath)": LINUser.self,
//                "\(kLINAPIPath)" + "\(kLINMatchUser)": LINUser.self,
//                "\(kLINAPIPath)" + "\(kLINLanguagePath)": LINLanguage.self,
//                "\(kLINAPIPath)" + "\(kLINConversationsPath)": LINConversation.self,
//                "\(kLINAPIPath)" + "\(kLINUploadPath)": LINFile.self,
//                "\(kLINAPIPath)" + "\(kLINMessagesPath)": LINReply.self
//        ]
//    }
    
    // MARK: Shared
    
    func setAuthorizedRequest() {
        let accessToken = LINStorageHelper.objectForKey(kLINAccessTokenKey) as? LINAccessToken
        if accessToken != nil {
            println("Bearer \(accessToken!.accessToken)")
            let requestSerializer = self.requestSerializer
            requestSerializer.setValue("Bearer \(accessToken!.accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
}

// MARK: Oauth token

extension LINNetworkClient {
    
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
        
        let path = "\(kLINAPIPath)" + "\(kLINGetCurrentUserPath)"
        self.GET(path, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Token is not valid.")
                completion(success: false)
            } else {
                println("Token is valid.")
                completion(success: true)
            }
        })
    }
}

// MARK: Users

extension LINNetworkClient {
    
    func getCurrentUser(success: (user: LINUser?) -> Void,
                        failture: (error: NSError?) -> Void) {
            setAuthorizedRequest()
            
            let path = "\(kLINAPIPath)" + "\(kLINGetCurrentUserPath)"
            self.GET(path, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
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
            var path = "\(kLINAPIPath)" + "\(kLINUsersPath)"
                            
            if let currentUser = LINUserManager.sharedInstance.currentUser {
                path = "\(path)/\(currentUser.userId)"
                parameters = ["avatar_url": currentUser.avatarURL,
                              "firstname": currentUser.firstName,
                              "lastname": currentUser.lastName,
                              "gender": currentUser.gender,
                              "learn_language_id": currentUser.learningLanguage!.languageID,
                              "native_language_id":     currentUser.nativeLanguage!.languageID,
                              "spoken_proficiency_id":  currentUser.speakingProficiency!.proficiencyID,
                              "written_proficiency_id": currentUser.writingProficiency!.proficiencyID,
                              "introduction" :          currentUser.introduction]
            }
            else {
                return
            }
            
            self.PUT(path, parameters: parameters, completion: { (response: AnyObject?, error: NSError?) -> Void in
                if error != nil {
                    failture(error: error)
                    return
                }
                LINStorageHelper.setObject(LINUserManager.sharedInstance.currentUser, forKey: kLINCurrentUserKey)
                success()
            })
    }
    
    func getAllUsers(success: (arrUsers: [LINUser]?) -> Void,
                     failture: (error: NSError?) -> Void) {
            setAuthorizedRequest()
            
            let path = "\(kLINAPIPath)" + "\(kLINUsersPath)"
            self.GET(path, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
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
        
        let parameters = [kLINUserIdKey: userId,
                          "message": text,
                          "time_created": sendDate]
        let path = "\(kLINAPIPath)" + "\(kLINSendNotification)"
        
        self.POST(path, parameters: parameters, completion: nil)
    }
    
    func updateDeviceTokenWithUserId(userId: String, deviceToken: String) {
        setAuthorizedRequest()
        
        let parameters = [kLINUserIdKey: userId,
            kLINDeviceTokenKey: deviceToken]
        let path = "\(kLINAPIPath)" + "\(kLINUsersPath)/\(userId)"

        self.PUT(path, parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Update device token has some errors: \(error!.description)")
            } else {
                println("Update device token successfully.")
            }
        })
    }
    
    func matchUser(partnerRole: LINPartnerRole, success: (arrUsers: [LINUser]) -> Void, failture: (error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        let parameters = ["partner_role": partnerRole.stringFromRole()]
        let path = "\(kLINAPIPath)" + "\(kLINMatchUser)"
        
        self.GET(path, parameters: parameters, completion: { (response: AnyObject?, error: NSError?) -> Void in
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

    func callActionAPI(actionType:LINActionType, userId:String, completion:(error:NSError?) -> Void ) {
        var path = "\(kLINAPIPath)"

        switch actionType {
            case .LINActionTypeFlag:
                path += "\(kLINSetFlagPath)"
            case .LINActionTypeUnFlag:
                path += "\(kLINUnsetFlagPath)"
            case .LINActionTypeLike:
                path += "\(kLINLikePath)"
            case .LINActionTypeUnLike:
                path += "\(kLINUnlikePath)"
            default:
                break
            }

        path = path.stringByReplacingOccurrencesOfString("*", withString: "\(userId)", options: nil, range: nil)

        self.POST(path, parameters: nil, { (response: AnyObject?, error: NSError?) -> Void in
            completion(error: error)
        })
    }
}

// MARK: Conversations

extension LINNetworkClient {
    
    func createNewConversationWithTeacherId(teacherId: String, learnerId: String,
                                            success: (conversation: LINConversation) -> Void,
                                            failure: (error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        let parameters = ["teacher_id": teacherId,
                          "learner_id": learnerId]
        let path = "\(kLINAPIPath)" + "\(kLINConversationsPath)"
                                                
        self.POST(path, parameters: parameters, { (response: AnyObject?, error: NSError?) -> Void in
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
        
        let path = "\(kLINAPIPath)" + "\(kLINConversationsPath)"
        self.GET(path, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Get all conversations has some errors: \(error!.description)")
                completion(conversationsArray: nil, error: error)
                return
            }
            
            if let tmpConversationArray = (response as OVCResponse).result as? [LINConversation] {
                println("You have \(tmpConversationArray.count) conversations.")
                completion(conversationsArray: tmpConversationArray, error: nil)
            }
        })
    }
    
    func creatBulkWithConversationId(conversationId: String,
                                     messagesArray: [AnyObject],
                                     completion: (success: Bool) -> Void) {
        setAuthorizedRequest()
        
        let path = "\(kLINAPIPath)" + "\(kLINConversationsPath)/\(conversationId)/messages"
        
        var error: NSError?
        let jsonData  = NSJSONSerialization.dataWithJSONObject(messagesArray, options: NSJSONWritingOptions(0), error: &error)
        if error != nil {
            println("Error creating JSON data from messages array: \(error!.description)");
            completion(success: false)
            return
        }
        
        self.POST(path, parameters: nil, constructingBodyWithBlock: { (formData) -> Void in
            formData.appendPartWithFormData(jsonData, name: "messages")
            }) { (response, error) -> Void in
                if error != nil {
                    println("Create a bulk of messages has some errors: \(error!.description)")
                    completion(success: false)
                    return
                }
                
                println("Create a bulk of messages successfully.")
                completion(success: true)
        }
    }
    
    func getChatHistoryWithConversationId(conversationId: String, length: Int, page: Int,
                                          completion: (repliesArray: [LINReply]?, error: NSError?) -> Void) {
        setAuthorizedRequest()
        
        let parameters = ["conversation_id": conversationId,
                          "length": length,
                          "page": page]
        var path = "\(kLINAPIPath)" + "\(kLINMessagesPath)"
        path = path.stringByReplacingOccurrencesOfString("*", withString: "\(conversationId)", options: nil, range: nil)
        
        self.GET(path, parameters: parameters) { (response, error) -> Void in
            if error != nil {
                println("Get chat history has some errors: \(error!.description)")
                completion(repliesArray: nil, error: error!)
                return
            }
            
            if let tmpRepliesArray = (response as OVCResponse).result as? [LINReply] {
                println("You have \(tmpRepliesArray.count) messages.")
                completion(repliesArray: tmpRepliesArray, error: nil)
            }
        }
    }
    
    func leaveConversationWithConversationId(conversationId: String, completion: (success: Bool) -> Void){
        setAuthorizedRequest()
        
        var path = "\(kLINAPIPath)" + "\(kLINLeaveConversationPath)"
        path = path.stringByReplacingOccurrencesOfString("*", withString: "\(conversationId)", options: nil, range: nil)
        
        self.PUT(path, parameters: nil) { (response, error) -> Void in
            if error != nil {
                println("Leave conversation has some errors: \(error!.description)")
                completion(success: false)
                return
            }
            
            println("Leave conversation successfully.")
            completion(success: true)
       }
    }
}

// MARK: Photos, Voices

extension LINNetworkClient {
    
    func uploadFile(data: NSData,
                    fileType: LINFileType,
                    completion: (fileURL: String?, error: NSError?) -> Void) {
        let fileInfo = fileType.getFileInfo()
        let path = "\(kLINAPIPath)" + "\(kLINUploadPath)"
                        
        self.POST(path, parameters: nil, constructingBodyWithBlock: { (formData) -> Void in
            formData.appendPartWithFileData(data, name: "file", fileName: fileInfo.fileName, mimeType: fileInfo.mimeType)
        }) { (response, error) -> Void in
                if error != nil {
                    println("Upload file has some errors: \(error!.description)")
                    completion(fileURL: nil, error: error!)
                    return
                }
                
                if var tmpFile = (response as OVCResponse).result as? LINFile {
                    tmpFile.fileURL += "?width=\(tmpFile.width)&height=\(tmpFile.height)"
                    println("File URL: \(tmpFile.fileURL)")
                    completion(fileURL: tmpFile.fileURL, error: nil)
                }
        }
    }

    func downloadFile(url: String, completion: (data: NSData?, error: NSError?) -> Void) {
        let operation = AFHTTPRequestOperation(request: NSURLRequest(URL: NSURL(string: url)!))
        operation.setCompletionBlockWithSuccess({ (operation, data) in
            if let tmpData = data as? NSData {
                completion(data: tmpData, error: nil)
            }
            else {
                completion(data: nil, error: nil)
            }
        }, failure: { (operation, error) in
            println("*** Failed to download the file")
            completion(data: nil, error: error)
        })
        operation.start()
    }
}

// MARK: Languages

extension LINNetworkClient {
    
    func getLanguages(success: (languages: [[LINLanguage]], headers: [String]) -> Void, failture: (error: NSError?) -> Void) {
        let path = "\(kLINAPIPath)" + "\(kLINLanguagePath)"
        self.GET(path, parameters: nil, completion: { (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                failture(error: error)
                return
            }
            
            if var languages = (response as OVCResponse).result as? [LINLanguage] {
                languages.sort {
                    switch $0.languageName.localizedCaseInsensitiveCompare($1.languageName) {
                    case .OrderedAscending: return true
                    default: return false
                    }
                }
                var headers = languages.map { "\(Array($0.languageName)[0])" }
                var distinctHeaders = [headers[0]] //Initialize with first object from Headers
                var structedArray: [[LINLanguage]] = [[languages[0]]] //Initialize with first object from Languages
                var structedArrayIndex = structedArray.count - 1
                for var i = 1; i < headers.count; i++ {
                    if headers[i] == headers[i - 1] {
                        structedArray[structedArrayIndex].append(languages[i])
                    }
                    else {
                        distinctHeaders.append(headers[i])
                        var subArray = [languages[i]]
                        structedArray.append(subArray)
                        structedArrayIndex++
                    }
                }
                success(languages: structedArray, headers: distinctHeaders)
                return
            }
            
            failture(error: nil)
        })
    }
}

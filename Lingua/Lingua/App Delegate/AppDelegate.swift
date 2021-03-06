//
//  AppDelegate.swift
//  Lingua
//
//  Created by Hoang Ta on 6/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storyboard = UIStoryboard()
    var drawerController = MMDrawerController()
    var mainNavigationController: UINavigationController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        setupAppearance()
        
        Parse.setApplicationId("OMS2KayfQ1rDTjkWvAjdiF3GFkxTD9hoPR9SnLSR", clientKey: "JPXeT1Kelnsw66qLwQlrOAP69ybbLXhb5Bvh7YQ5")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        LINPusherManager.sharedInstance.connectToPusher()
        
        registerRemoteNotification(application: application)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.makeKeyAndVisible()
        
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        mainNavigationController = storyboard.instantiateViewControllerWithIdentifier("kRootNavigationController") as? UINavigationController
        window!.rootViewController = mainNavigationController
        
        // Check If User logined
        if LINUserManager.sharedInstance.isLoggedIn() && LINUserManager.sharedInstance.currentUser?.learningLanguage != nil {
            showHomeScreen(animated: false)
            
            // App launched via push notification
            let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
            if userInfo != nil {
                LINNotificationHelper.handlePushNotificationWithUserInfo(userInfo!, applicationState: application.applicationState)
            }
        }
        
        LINNetworkHelper.setupWithDefaultViewController(window!.rootViewController!)
        
        return true
    }
    
    // MARK: Utility methods
    
    private func registerRemoteNotification(#application: UIApplication) {
        if application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
    }

    private func setupAppearance() {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UINavigationBar.appearance().setBackgroundImage(UIImage.navigationBarBackgroundImage(), forBarMetrics:UIBarMetrics.Default)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    class func sharedDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate! as AppDelegate
    }
    
    func showHomeScreen(#animated: Bool) {
        let leftDrawer = storyboard.instantiateViewControllerWithIdentifier("kLINMyProfileController") as LINMyProfileController
        let center = storyboard.instantiateViewControllerWithIdentifier("kLINHomeController") as LINHomeController
        let rightDrawer = storyboard.instantiateViewControllerWithIdentifier("kLINFriendListController") as LINFriendListController
        
        drawerController = MMDrawerController(centerViewController: center, leftDrawerViewController: leftDrawer, rightDrawerViewController: rightDrawer)
        drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
        drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView | MMOpenDrawerGestureMode.PanningNavigationBar

        mainNavigationController!.pushViewController(drawerController, animated: animated)
    }
    
    func showOnboardingScreen() {
        mainNavigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: UIApplicationDelegate
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet = NSCharacterSet(charactersInString: "<>")
        let token = (deviceToken.description as NSString).stringByTrimmingCharactersInSet(characterSet)
                                                         .stringByReplacingOccurrencesOfString(" ", withString: "") as String
        println("Device token: \(token)")
        
        LINStorageHelper.setStringValue(token, forkey: kLINDeviceTokenKey)
        
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error: NSError! ) {
        println("Fail to register remote notification: \(error.localizedDescription)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        LINNotificationHelper.handlePushNotificationWithUserInfo(userInfo, applicationState: application.applicationState)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLINNotificationAppDidEnterBackground, object: nil)
        
        LINStorageHelper.updateLastOnlineTimeStamp()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.git 
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppCall.handleDidBecomeActive()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLINNotificationAppDidBecomActive, object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
        if (url.absoluteString?.hasPrefix("fb") != nil) {
            return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        }
        
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation) 
    }

    // #pragma mark - Core Data stack

    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle.mainBundle().URLForResource("Lingua", withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        return _managedObjectModel!
    }
    var _managedObjectModel: NSManagedObjectModel? = nil

    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator == nil {
            let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Lingua.sqlite")
            var error: NSError? = nil
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
                /*
                Replace this implementation with code to handle the error appropriately.

                abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                Typical reasons for an error here include:
                * The persistent store is not accessible;
                * The schema for the persistent store is incompatible with current managed object model.
                Check the error message to determine what the actual problem was.


                If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

                If you encounter schema incompatibility errors during development, you can reduce their frequency by:
                * Simply deleting the existing store:
                NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)

                * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
                [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true}

                Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

                */
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
        return _persistentStoreCoordinator!
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

    // #pragma mark - Application's Documents directory
                                    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as NSURL
    }

}


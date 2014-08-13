//
//  LINStorageHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/28/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINStorageHelper {
    
    class func objectForKey(key: String) -> AnyObject? {
        if key.utf16Count == 0 {
            return nil
        }
        
        let data = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData
        if data  == nil {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(data)
    }
    
    class func setObject(value: AnyObject?, forKey key: String) {
        if key.utf16Count == 0 {
            return
        }
        
        let data: NSData? = NSKeyedArchiver.archivedDataWithRootObject(value)
        if data == nil {
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setStringValue(value: String, forkey key: String) {
        if key.utf16Count == 0 {
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getStringValueForKey(key: String) -> String? {
        if key.utf16Count == 0 {
            return nil
        }
        
        return NSUserDefaults.standardUserDefaults().objectForKey(key) as? String
    }
    
    class func getLastOnlineTimeStamp()->NSDate?{
        let lastOnlineDate = NSUserDefaults.standardUserDefaults().objectForKey(kLINLastOnlineKey) as? NSDate
        if lastOnlineDate != nil{
            return lastOnlineDate
        }
        return nil
    }
    
    class func updateLastOnlineTimeStamp(){
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: kLINLastOnlineKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
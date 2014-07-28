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
}
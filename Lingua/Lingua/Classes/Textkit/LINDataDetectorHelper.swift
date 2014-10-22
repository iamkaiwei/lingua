//
//  LINDataDetectorHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINDataDetectorHelper {
    
    func getTextTypeWithString(str: String) -> NSTextCheckingType? {
       let dataDetector = LINDataDetectorHelper.getDataDetector()
        var resutType: NSTextCheckingType?
        
        dataDetector.enumerateMatchesInString(str, options: NSMatchingOptions(0), range: NSMakeRange(0, str.utf16Count)) {
            (result, flags, stop) -> Void in
                resutType = result.resultType
        }
        
        return resutType
    }
    
    class func getDataDetector() -> NSDataDetector {
        struct Static {
            static var dataDetector: NSDataDetector?
        }
        
        if Static.dataDetector == nil {
            Static.dataDetector = NSDataDetector(types: UInt64(NSTextCheckingAllTypes), error: nil)
        }
        
        return Static.dataDetector!
    }
}
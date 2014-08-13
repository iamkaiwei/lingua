//
//  NSDateFormatter+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/4/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    class var dateDefaultFormat: String {
        return "yyyy-MM-dd HH:mm:ss zzz"
    }
    
    class var hourDefaultFormat: String {
        return "HH:mm a"
    }
    
    class func stringWithDefautFormatFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateDefaultFormat
        
        let result = dateFormatter.stringFromDate(date)
        return result
    }
    
    class func dateWithDefaultFormatFromString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateDefaultFormat

        let result = dateFormatter.dateFromString(string)
        return result
    }
    
    class func hourStringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = hourDefaultFormat
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let result = dateFormatter.stringFromDate(date)
        return result.lowercaseString
    }
    
    class func iSODateFormatter() -> NSDateFormatter {
        struct Static {
            static var iSODateFormatter:NSDateFormatter? = nil
        }
        if Static.iSODateFormatter == nil {
            Static.iSODateFormatter = NSDateFormatter()
            Static.iSODateFormatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        }
        return Static.iSODateFormatter!
    }
    
}
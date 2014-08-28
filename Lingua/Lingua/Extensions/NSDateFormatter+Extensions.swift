//
//  NSDateFormatter+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/4/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    class func hourDateFormatter() -> NSDateFormatter {
        struct Static {
            static var instance: NSDateFormatter?
        }
        if Static.instance == nil {
            Static.instance = NSDateFormatter()
            Static.instance?.dateFormat = "HH:mm a"
            Static.instance?.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        return Static.instance!
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
    
    class func utcDateFormatter() -> NSDateFormatter {
        struct Static {
            static var utcDateFormatter:NSDateFormatter? = nil
        }
        if Static.utcDateFormatter == nil {
            Static.utcDateFormatter = NSDateFormatter()
            Static.utcDateFormatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            Static.utcDateFormatter?.timeZone = NSTimeZone(name: "UTC")
        }
        return Static.utcDateFormatter!
    }
    
    class func convertToUTC(date:NSDate) -> NSDate {
        var dateString:String = NSDateFormatter.iSODateFormatter().stringFromDate(date)
        return NSDateFormatter.utcDateFormatter().dateFromString(dateString)!
    }

    class func conversationDateFormatter() -> NSDateFormatter {
        struct Static {
            static var conversationDateFormatter:NSDateFormatter? = nil
        }
        if Static.conversationDateFormatter == nil {
            Static.conversationDateFormatter = NSDateFormatter()
            Static.conversationDateFormatter?.dateFormat = "EEEE"
        }
        return Static.conversationDateFormatter!
    }
    
    class func getConversationTimeStringFromDate(date: NSDate) -> String {
        var calendar:NSCalendar = NSCalendar.currentCalendar()
        var dateComponents:NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay , fromDate: date)
            
        var currentDate = NSDate()
        var differentInDays:Int = calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitEra, forDate: date) - calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitEra, forDate: currentDate)
    
        var dayString:String = ""
            
        if differentInDays  == 0{
            dayString = NSDateFormatter.hourDateFormatter().stringFromDate(date).lowercaseString
        }
        else if differentInDays == -1 {
            dayString = "Yesterday"
        }
        else if differentInDays < -1 && differentInDays >= -6 {
            dayString = NSDateFormatter.conversationDateFormatter().stringFromDate(date)
        }
        else {
            dayString = "\(dateComponents.day)/\(dateComponents.month)/\(dateComponents.year)"
        }
        return dayString
    }
}
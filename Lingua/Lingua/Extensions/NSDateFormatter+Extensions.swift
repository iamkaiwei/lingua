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
    
    class func getConversationTimeStringFromDate(date:NSDate) -> String {
        if date != nil{
            var calendar:NSCalendar = NSCalendar.currentCalendar()
            var dateComponents:NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay , fromDate: date)
            
            var currentDate = NSDate()
            var differentInDays:Int = calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitEra, forDate: date) - calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitEra, forDate: currentDate)
    
            var dayString:String = ""
            
            if differentInDays  == 0{
                dayString = self.hourStringFromDate(date)
            }
            else if differentInDays == -1 {
                dayString = "Yesterday"
            }else if differentInDays < -1 && differentInDays >= -6 {
                dayString = NSDateFormatter.conversationDateFormatter().stringFromDate(date)
            }
            else
            {
                dayString = "\(dateComponents.day)/\(dateComponents.month)/\(dateComponents.year)"
            }
            return dayString
        }
        return ""
    }
}
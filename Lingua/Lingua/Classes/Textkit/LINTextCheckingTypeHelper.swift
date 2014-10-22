//
//  LINTextCheckingTypeHelper.swift
//  Lingua
//
//  Created by Kiet Nguyen on 10/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINTextCheckingTypeHelper {
    var checkingType: NSTextCheckingType?
    
    init(checkingType: NSTextCheckingType?) {
        self.checkingType = checkingType
    }
    
    func openURL(URL: NSURL) {
        if self.checkingType != nil {
            let urlHepler = LINURLHelper()
            
            switch(self.checkingType!) {
            case NSTextCheckingType.Link:
                urlHepler.openURL(URL)
            case NSTextCheckingType.PhoneNumber:
                urlHepler.openURL(NSURL(string: "tel:\(URL.absoluteString!)")!)
            default:
                break
            }
        }
    }
}

class LINURLHelper {
    
    func openURL(URL: NSURL) {
        UIApplication.sharedApplication().openURL(URL)
    }
}
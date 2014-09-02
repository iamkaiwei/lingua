//
//  NSURL+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 9/2/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension NSURL {
    func queryParameters() -> NSDictionary {
        let query: String = self.query!
        var result: NSMutableDictionary = NSMutableDictionary()
        let parameters = query.componentsSeparatedByString("&")
        for parameter in parameters {
            let parts = parameter.componentsSeparatedByString("=")
            let key = (parts[0] as NSString).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            if parts.count > 1 {
                let value = (parts[1] as NSString).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                result[key!] = value
            }
        }
        return result
    }
}
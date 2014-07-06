//
//  NSArray-Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension NSArray {
    class func facebookPermissionArray() -> NSArray {
        return ["user_about_me", "email", "user_birthday", "user_location"]
    }
}
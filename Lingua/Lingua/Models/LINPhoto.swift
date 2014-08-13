//
//  LINPhoto.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/13/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINPhoto: MTLModel, MTLJSONSerializing {
    var imageURL: String = ""
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["imageURL": "image_url"]
    }
}
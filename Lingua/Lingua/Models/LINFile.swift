//
//  LINFile.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/13/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

enum LINFileType {
    case Image, Audio
    
    func getFileInfo() -> (fileName: String, mimeType: String) {
        var tmpFileName = "\(NSDate().timeIntervalSince1970)"
        var tmpMimeType = ""
        switch (self) {
            case Image:
                tmpFileName += ".jpg"
                tmpMimeType = "image/jpeg"
            case Audio:
                tmpFileName += ".caf"
                tmpMimeType = "audio/caf"
            default:
                break
        }
        return (tmpFileName, tmpMimeType)
    }
}

class LINFile: MTLModel, MTLJSONSerializing {
    var fileURL: String = ""
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["fileURL": "file_url"]
    }
}
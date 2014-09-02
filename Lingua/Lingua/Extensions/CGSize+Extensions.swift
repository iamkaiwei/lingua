//
//  CGSize+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 9/2/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension CGSize {
    static func getSizeFromImageURL(imageURL: String) -> CGSize {
        let dict = NSURL(string: imageURL).queryParameters()
        let width = dict["width" as NSString]?.doubleValue
        let height = dict["height" as NSString]?.doubleValue
        return CGSize(width: width!, height: height!)
    }

    func scaledSize() -> CGSize {
        var newSize = self
        if self.width > kPhotoMessageMaxWidth {
            newSize.height /= self.width / kPhotoMessageMaxWidth
            newSize.width = kPhotoMessageMaxWidth
        }
        return newSize
    }
}
//
//  LINUImage+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/27/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UIImage {
    func scaleSize() -> CGSize {
        var newSize = self.size
        if self.size.width > kPhotoMessageMaxWidth {
            newSize.height /= self.size.width / kPhotoMessageMaxWidth
            newSize.width = kPhotoMessageMaxWidth
        }
        return newSize
    }
}
//
//  String-Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension String {
    func length() -> Int {
        return self.lengthOfBytesUsingEncoding(NSUTF16StringEncoding)
    }
}
//
//  UITextView+Extensions.swift
//  Lingua
//
//  Created by TaiVuong on 8/31/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UITextView {
    func scrollToCaret() {
        self.layoutManager.ensureLayoutForTextContainer(self.textContainer)
        var caretRect:CGRect = self.caretRectForPosition(self.endOfDocument)
        self.scrollRectToVisible(caretRect, animated: false)
    }
}


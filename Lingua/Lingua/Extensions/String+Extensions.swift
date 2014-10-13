//
//  String+Extensions.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/25/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension String {
    func sizeOfStringUseTextStorage() -> CGSize {
        struct Static {
            static var textView: UITextView?
            static var emoticonsTextStorage: LINParsingEmoticonsTextStorage?
        }

        if Static.textView == nil {
            Static.textView = UITextView()
            Static.emoticonsTextStorage = LINParsingEmoticonsTextStorage()
            Static.emoticonsTextStorage!.addLayoutManager(Static.textView!.layoutManager)
        }

        Static.emoticonsTextStorage!.setAttributedString(NSAttributedString(string: self))
        return Static.textView!.sizeThatFits(CGSize(width: LINBubbleCell.maxWidthOfMessage(), height: kLINTextMessageMaxHeight))
    }
}
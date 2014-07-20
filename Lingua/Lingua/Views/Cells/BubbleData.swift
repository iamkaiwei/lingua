//
//  BubbleData.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

enum BubbleType {
    case Mine, SomeoneElse
}

let textInsetsMine = UIEdgeInsetsMake(5, 10, 7, 17)
let textInsetsSomeone = UIEdgeInsetsMake(5, 15, 7, 10)

class BubbleData {
    var type: BubbleType
    var view: UIView
    var insets: UIEdgeInsets
    var content: String
    var timeCreated: NSDate
    
    init(text: String, createAt: NSDate, bubbleType: BubbleType) {
        let font = UIFont.appRegularFontWithSize(14)
        let rect = (text as NSString).boundingRectWithSize(CGSize(width: 233, height: 9999),
                                             options: .UsesLineFragmentOrigin,
                                             attributes: [NSFontAttributeName: font],
                                             context: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.text = text
        label.font = font
        label.backgroundColor = UIColor.clearColor()

        insets = (bubbleType == .Mine ? textInsetsMine : textInsetsSomeone)
        
        view = label
        type = bubbleType;
        content = text
        timeCreated = createAt
    }
}
    
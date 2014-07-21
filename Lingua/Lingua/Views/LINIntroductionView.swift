//
//  LINIntroductionView.swift
//  Lingua
//
//  Created by Hoang Ta on 7/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINIntroductionView: UIView {

    var introduction: String = "" {
        didSet {
            let font = UIFont.appRegularFontWithSize(14)
            let rect = NSString(string: introduction).boundingRectWithSize(CGSize(width: frame.size.width, height: 9999),
                options: .UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil)
        }
    }
    
    func commonInit() {
        backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        let bubbleImage = UIImageView(frame: bounds)
        bubbleImage.image = UIImage(named: "ChatBoxLeft")
        addSubview(bubbleImage)
    }
}

//
//  LINIntroductionView.swift
//  Lingua
//
//  Created by Hoang Ta on 7/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINIntroductionViewDelegate {
    func introductionView(introductionView: LINIntroductionView, didChangeToHeight height: CGFloat)
}

class LINIntroductionView: UIView {

    var delegate: LINIntroductionViewDelegate?
    private var introductionLabel: UILabel?
    private var bubbleImage: UIImageView?
    var introduction: String = "" {
        didSet {
            introductionLabel!.text = introduction
            let font = UIFont.appRegularFontWithSize(13)
            var rect = NSString(string: introduction).boundingRectWithSize(CGSize(width: frame.size.width - 20, height: 9999),
                options: .UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil)
            
            //Resize label
            rect.origin = CGPointMake(10, 15)
            introductionLabel!.frame = rect
            
            //Resize bubbleImage
            var tempFrame = self.bounds
            tempFrame.size.height = CGRectGetHeight(rect) + 20
            bubbleImage!.frame = tempFrame
            
            //Resize this
            tempFrame.origin = self.frame.origin
            self.frame = tempFrame
            //** Maybe we should add layout constraints to commonInit() instead of changing subviews' frame..
            
            delegate?.introductionView(self, didChangeToHeight: CGRectGetHeight(self.frame))
        }
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        bubbleImage = UIImageView(frame: bounds)
        bubbleImage!.image = UIImage(named: "ChatBoxLeft")
        addSubview(bubbleImage!)
        
        introductionLabel = UILabel()
        introductionLabel!.font = UIFont.appRegularFontWithSize(13)
        introductionLabel!.numberOfLines = 0
        addSubview(introductionLabel!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

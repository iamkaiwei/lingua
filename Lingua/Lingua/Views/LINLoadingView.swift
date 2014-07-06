//
//  LINLoadingView.swift
//  Lingua
//
//  Created by Hoang Ta on 7/5/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINLoadingView: UIView {

    var currentSnap = 0
    var timer: NSTimer?
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "moveAround", userInfo: nil, repeats: true)
        layer.cornerRadius = CGRectGetHeight(frame) / 2
        clipsToBounds = true
    }
    
    override var hidden: Bool {
    didSet {
        if hidden {
            timer?.invalidate()
        } else {
            timer?.fire()
        }
    }
    }
    
    func moveAround() {
        currentSnap++;
        if currentSnap == 5 {
            self.currentSnap = 0;
        }
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect)
    {
        UIColor.appTealColor().setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
        
        UIColor.whiteColor().setFill()
        
        let delta = rect.size.width / 16;
        let halfDelta = delta / 2;
        let maxY = rect.size.height;
        let additionalOffset = (delta / 5) * CGFloat(currentSnap);
        
        for i in -1..16 {
            let minX = CGFloat(i) * delta + additionalOffset
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(minX, maxY))
            path.addLineToPoint(CGPointMake(minX + halfDelta, 0))
            path.addLineToPoint(CGPointMake(minX + delta, 0))
            path.addLineToPoint(CGPointMake(minX + halfDelta, maxY))
            path.closePath()
            path.fill()
        }
    }

}

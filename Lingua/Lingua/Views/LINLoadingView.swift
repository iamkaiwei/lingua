//
//  LINLoadingView.swift
//  Lingua
//
//  Created by Hoang Ta on 7/5/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINLoadingView: UIView {

    private var currentSnap = 0
    private var timer: NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "doScroll", userInfo: nil, repeats: true)
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = CGRectGetHeight(frame) / 2
        clipsToBounds = true
        hidden = true
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        commonInit()
        timer.fire()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init() {
        super.init(frame: CGRectMake(0, 0, 159, 11))
        commonInit()
    }
    
    func showInView(view: UIView) {
        view.addSubview(self)
        self.center = view.center
        hidden = false
        timer.fire()
    }
    
    func hide() {
        hidden = true
        removeFromSuperview()
        timer.invalidate()
    }
    
    func doScroll() {
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
        
        for i in -1..<16 {
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

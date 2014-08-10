//
//  LINEmoticonsView.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/10/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINEmoticonsView: UIView {
    var isHidden: Bool = true
    
    // MARK: Functions
    
    func showInViewController(viewController: UIViewController) {
        viewController.view.addSubview(self)
        
        var frame = self.frame
        frame.origin.y = viewController.view.frame.size.height
        self.frame = frame
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            var frame = self.frame
            frame.origin.y = viewController.view.frame.size.height - self.frame.size.height
            self.frame = frame
            }, completion: { finished in
        })
        
        isHidden = false
    }
    
    func hide() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            var frame = self.frame
            frame.origin.y += self.frame.size.height
            self.frame = frame
            }, completion: { finished in
                self.removeFromSuperview()
        })
        
        isHidden = true
    }
}
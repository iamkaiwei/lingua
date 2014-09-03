//
//  PopPresentAnimationController.swift
//  Lingua
//
//  Created by Hoang Ta on 8/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINPopPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let finalFrame = transitionContext.finalFrameForViewController(toViewController!)
        let containerView = transitionContext.containerView()
        
        let screenBounds = UIScreen.mainScreen().bounds
        let intermediateView = toViewController!.view.snapshotViewAfterScreenUpdates(true)
        intermediateView.frame = CGRectInset(screenBounds, 50, 50)
        containerView.addSubview(intermediateView)
        
        let duration = transitionDuration(transitionContext)
        UIView.animateWithDuration(duration,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { intermediateView.frame = finalFrame },
            completion: { _ in
                intermediateView.removeFromSuperview()
                toViewController!.view.frame = finalFrame
                containerView.addSubview(toViewController!.view)
                transitionContext.completeTransition(true)
            })
    }
}
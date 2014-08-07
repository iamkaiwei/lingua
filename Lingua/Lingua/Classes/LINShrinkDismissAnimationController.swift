//
//  LINShrinkDismissAnimationController.swift
//  Lingua
//
//  Created by Hoang Ta on 8/7/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINShrinkDismissAnimationController : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning!) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning!) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()
        
        toViewController.view.frame = finalFrame
        containerView.addSubview(toViewController.view)
        
        let screenBounds = UIScreen.mainScreen().bounds
        let intermediateView = fromViewController.view.snapshotViewAfterScreenUpdates(false)
        containerView.addSubview(intermediateView)
        fromViewController.view.removeFromSuperview()
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.0,
            options: .CurveLinear,
            animations: {
                intermediateView.frame = CGRectInset(screenBounds, 50, 50)
                intermediateView.alpha = 0
            },
            completion: { _ in
                intermediateView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
    }
}
//
//  LINOnboardingViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINOnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareOnboarding()
    }
    
    func prepareOnboarding() {
        
        var frame = view.frame
        let onboarding = UIScrollView(frame: frame)
        onboarding.pagingEnabled = true
        onboarding.bounces = false
        onboarding.showsHorizontalScrollIndicator = false
        
        view.addSubview(onboarding)
        
        //Placeholder for onboarding
        for index in 0..3 {
            frame.origin.x = CGRectGetWidth(frame) * CGFloat(index)
            let pageView = UIView(frame: frame)
            pageView.backgroundColor = UIColor(red: Double(arc4random_uniform(255))/255.0, green: Double(arc4random_uniform(255))/255.0, blue: Double(arc4random_uniform(255))/255.0, alpha: 1)
            onboarding.addSubview(pageView)
        }
        
        //Login page
        frame.origin.x += CGRectGetWidth(frame)
        let loginView = LINLoginView(frame: frame);
        loginView.delegate = self
        onboarding.addSubview(loginView)
        
        onboarding.contentSize = CGSizeMake(CGRectGetMaxX(frame), CGRectGetHeight(frame))
    }
}

extension LINOnboardingViewController: LINLoginViewDelegate {
    
    func loginView(loginView: LINLoginView, didLoginWithOption: LoginOptions) {
        performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
    }
}
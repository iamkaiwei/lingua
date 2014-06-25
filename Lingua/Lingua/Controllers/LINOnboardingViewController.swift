//
//  LINOnboardingViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINOnboardingViewController: UIViewController {
    
    let kClientId = "749496516991-rn2ks5ka1jdbm7l040d0mhs4v0pja35j.apps.googleusercontent.com"
    let GPPSignInInstance = GPPSignIn.sharedInstance()
    
    @IBOutlet var onboardingView: UIScrollView
    @IBOutlet var pageControl : UIPageControl
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareOnboarding()
        configureGoogleLogin()
        configureFacebookLogin()
    }
    
    func prepareOnboarding() {
        
        var frame = view.frame
        
        //Placeholder for onboarding
        for index in 0..3 {
            frame.origin.x = CGRectGetWidth(frame) * CGFloat(index)
            let pageView = UIImageView(image: UIImage(named: "Onboarding\(index)"))
            pageView.frame = frame
            onboardingView.addSubview(pageView)
        }
        
        //Login page
        frame.origin.x += CGRectGetWidth(frame)
        let loginView = LINLoginView(frame: frame);
        loginView.delegate = self
        loginView.facebookLoginView.delegate = self
        onboardingView.addSubview(loginView)
        
        onboardingView.contentSize = CGSizeMake(CGRectGetMaxX(frame), CGRectGetHeight(frame))
    }
    
    func configureGoogleLogin() {
//        let GPPSignInInstance = GPPSignIn.sharedInstance()
        GPPSignInInstance.shouldFetchGooglePlusUser = true
        GPPSignInInstance.shouldFetchGoogleUserEmail = true
        GPPSignInInstance.clientID = kClientId
        GPPSignInInstance.scopes = [kGTLAuthScopePlusLogin]
//        GPPSignInInstance.scopes = [ "profile" ]
        GPPSignInInstance.delegate = self;
        GPPSignInInstance.trySilentAuthentication()
    }
    
    func configureFacebookLogin() {
        
    }
}

extension LINOnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    }
}

extension LINOnboardingViewController: LINLoginViewDelegate {
    
    func loginView(loginView: LINLoginView, option: LoginOptions) {
        switch option {
        case .Google:
            GPPSignInInstance.authenticate()
        case .Facebook: break
        default: break
        }
    }
}

extension LINOnboardingViewController: GPPSignInDelegate {
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            println("Received error \(error) and auth object \(auth)")
        } else {
            performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
        }
    }

    func presentSignInViewController(viewController: UIViewController!) {
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension LINOnboardingViewController: FBLoginViewDelegate {
    
    func loginView(loginView: FBLoginView!, error: NSError!) {
        println(error.localizedDescription)
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser) {
        performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
    }
    
}







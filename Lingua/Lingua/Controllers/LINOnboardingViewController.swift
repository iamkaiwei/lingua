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
    let signIn = GPPSignIn.sharedInstance()
    
    @IBOutlet var onboardingView: UIScrollView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareOnboarding()
        configureGPPSignIn()
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
        onboardingView.addSubview(loginView)
        
        onboardingView.contentSize = CGSizeMake(CGRectGetMaxX(frame), CGRectGetHeight(frame))
    }
    
    func configureGPPSignIn() {
//        let signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        signIn.clientID = kClientId
        signIn.scopes = [kGTLAuthScopePlusLogin]
//        signIn.scopes = [ "profile" ]
        signIn.delegate = self;
        signIn.trySilentAuthentication()
    }
}

extension LINOnboardingViewController: LINLoginViewDelegate {
    
    func loginView(loginView: LINLoginView, option: LoginOptions) {
        switch option {
        case .Google:
            signIn.authenticate()
        case .Facebook:
            performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
            
        default: break
        }
    }
}

extension LINOnboardingViewController: GPPSignInDelegate {
    
    func finishedWithAuth(auth: GTMOAuth2Authentication, error: NSError) {
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




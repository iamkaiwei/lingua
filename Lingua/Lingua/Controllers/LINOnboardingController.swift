//
//  LINOnboardingController.swift
//  Lingua
//  Updated by Kiet Nguyen on 7/7/2014.
//  Created by Hoang Ta on 6/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINOnboardingController: LINViewController {
    
    let kClientId = "749496516991-rn2ks5ka1jdbm7l040d0mhs4v0pja35j.apps.googleusercontent.com"
    let GPPSignInInstance = GPPSignIn.sharedInstance()
    
    @IBOutlet weak var onboardingView: UIScrollView!
    @IBOutlet weak var pageControl : UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        prepareOnboarding()
        configureGoogleLogin()
    }
    
    func prepareOnboarding() {
        var frame = view.frame
        for index in 0...2 {
            frame.origin.x = CGRectGetWidth(frame) * CGFloat(index)
            let pageView = UIImageView(image: UIImage(named: "Onboarding\(index)"))
            pageView.frame = frame
            onboardingView.addSubview(pageView)
        }
        
        // Login page
        frame.origin.x += CGRectGetWidth(frame)
        let loginView = LINLoginView(frame);
        loginView.delegate = self
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
}

extension LINOnboardingController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    }
}

extension LINOnboardingController: LINLoginViewDelegate {
    
    func loginView(loginView: LINLoginView, option: LoginOptions) {
        switch option {
        case .Google:
            GPPSignInInstance.authenticate()
        case .Facebook:
            loginWithFacebook(loginView)
            break
        default:
            break
        }
    }
    
    func loginWithFacebook(loginView: LINLoginView) {
//        LINUserManager.sharedInstance.loginWithFacebookOnSuccess(
//        { (user: PFUser?) -> Void in
//            println("User with facebook logged in!");
//            
//            loginView.stopActivityIndicatorView()
//            self.performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
//        },
//        { (error: NSError?) -> Void in
//            loginView.stopActivityIndicatorView()
//            
//            var alert = UIAlertView()
//            if (!error) {
//               alert = UIAlertView(title: "Facebook Login Failed", message: "Make sure you've allowed Lingua to use Facebook in iOS Settings > Privacy > Facebook.", delegate: nil, cancelButtonTitle: "OK")
//            } else {
//                alert = UIAlertView(title: "Facebook Login Failed", message: "The Internet connection appears to be offline.", delegate: nil, cancelButtonTitle: "OK")
//            }
//            alert.show()
//        })
//        
//        loginView.startActivityIndicatorView()
    }
}

extension LINOnboardingController: GPPSignInDelegate {
    
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
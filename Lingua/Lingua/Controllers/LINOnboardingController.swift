//
//  LINOnboardingController.swift
//  Lingua
//  Updated by Kiet Nguyen on 7/7/2014.
//  Created by Hoang Ta on 6/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINOnboardingController: LINViewController, LINFacebookManagerDelegate {
    
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
        LINFacebookManager.sharedInstance.delegate = self
        LINFacebookManager.sharedInstance.openSessionWithAllowLoginUI(true)
    }
    
    // MARK: LINFacebookManager Delegate
    
    func facebookLoginSuccessed(facebookManager: LINFacebookManager)  {
        
        SVProgressHUD.showWithStatus("Signing In ...")
        
        LINUserManager.sharedInstance.loginWithFacebookToken(LINFacebookManager.sharedInstance.facebookToken, completion: {
            (success: Bool) -> Void in
            if success {
                SVProgressHUD.dismiss()
                self.performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
            } else {
                SVProgressHUD.dismiss()
                UIAlertView(title: "Login Failed", message: "Facebook login unsuccessful. Please try again!", delegate: nil, cancelButtonTitle: "OK").show()
            }
        })
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
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        onboardingView.scrollRectToVisible(onboardingView.frame, animated: false)
    }
    
    func prepareOnboarding() {
        var frame = view.frame
        var pageView: UIView
        for index in 0...3 {
            frame.origin.x = CGRectGetWidth(frame) * CGFloat(index)
            if index < 3 {
                pageView = UIImageView(image: UIImage(named: "Onboarding\(index)"))
            }
            else {
                pageView = LINLoginView(view.frame)
                let castPageView = pageView as LINLoginView
                castPageView.delegate = self
            }
            pageView.frame = frame
            onboardingView.addSubview(pageView)
        }
        
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

// MARK: UIScrollViewDelegate

extension LINOnboardingController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    }
}

// MARK: LINLoginViewDelegate

extension LINOnboardingController: LINLoginViewDelegate {
    
    func loginView(loginView: LINLoginView, option: LINLoginOptions) {
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
                if LINUserManager.sharedInstance.currentUser?.learningLanguage != nil {
                    self.showHomeScreen()
                }
                else {
                    self.performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
                }
                return
            }
            
            self.loginFacebookFailed()
        })
    }
    
    func facebookLoginFailed(facebookManager: LINFacebookManager) {
        loginFacebookFailed()
    }
    
    private func loginFacebookFailed() {
        SVProgressHUD.dismiss()
        UIAlertView(title: "Login Failed", message: "Facebook login unsuccessful. Please try again!", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func showHomeScreen() {
         AppDelegate.sharedDelegate().showHomeScreen(animated: true)
        
        //Post this notification to make sure that ConversationList will be refreshed after logged-in
         NSNotificationCenter.defaultCenter().postNotificationName(kLINNotificationAppDidBecomActive, object: nil)
    }
}

// MARK: GPPSignInDelegate

extension LINOnboardingController: GPPSignInDelegate {
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            println("Received error \(error) and auth object \(auth)")
        } else {
            performSegueWithIdentifier("kPickLearningViewControllerSegue", sender: self)
        }
    }

    func presentSignInViewController(viewController: UIViewController!) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}
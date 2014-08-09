//
//  LINPickNativeLanguageController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickNativeLanguageController: LINViewController {

    @IBOutlet weak var subtitle1: UILabel!
    @IBOutlet weak var subtitle2: UILabel!
    @IBOutlet weak var languagePickerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var textView: SZTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        arrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        subtitle1.font = UIFont.appRegularFontWithSize(17)
        subtitle2.font = UIFont.appThinFontWithSize(14)
        saveButton.titleLabel.font = UIFont.appRegularFontWithSize(21)
        textView.tintColor = UIColor.appTealColor()
        textView.font = UIFont.appLightFontWithSize(14)
        textView.placeholder = "Write an introduction about yourself in your native language. This will help other users find you."
        textView.placeholderTextColor = UIColor.grayColor()
        textView.layoutManager.delegate = self
        textView._placeholderTextView.layoutManager.delegate = self
    }
    
    @IBAction func saveUserInfo(sender: UIButton) {
        if LINUserManager.sharedInstance.currentUser?.nativeLanguage == nil {
            UIAlertView(title: nil, message: "You have to choose a native language.", delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        
        LINNetworkClient.sharedInstance.updateCurrentUser({ _ in
            self.showHome()
            }, failture: { println($0)})
    }
    
    func showHome() {
        AppDelegate.sharedDelegate().showHomeScreenWithNavigationController(navigationController)
    }
    
    @IBAction func showCountryList(sender: UITapGestureRecognizer) {
        let viewController = storyboard.instantiateViewControllerWithIdentifier("kLINLanguagePickerController") as LINLanguagePickerController
        viewController.delegate = self
        navigationController!.pushViewController(viewController, animated: true)
    }
}

extension LINPickNativeLanguageController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager!, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}

extension LINPickNativeLanguageController: LINLanguagePickerControllerDelegate {
    func controller(controller: LINLanguagePickerController, didSelectLanguage language: LINLanguage) {
        LINUserManager.sharedInstance.currentUser?.nativeLanguage = language
        subtitle2.text = language.languageName
    }
}
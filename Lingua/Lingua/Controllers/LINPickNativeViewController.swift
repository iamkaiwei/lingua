//
//  LINPickNativeViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickNativeViewController: LINViewController {

    @IBOutlet var subtitle1: UILabel
    @IBOutlet var subtitle2: UILabel
    @IBOutlet var languagePickerView: UIView
    @IBOutlet var saveButton: UIButton
    @IBOutlet var arrowImageView: UIImageView
    @IBOutlet var textView: SZTextView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2)
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
        AppDelegate.sharedDelegate().showHomeScreenWithNavigationController(navigationController)
    }

    @IBAction func showCountryList(sender: UITapGestureRecognizer) {
        let viewController = storyboard.instantiateViewControllerWithIdentifier("kLINCountrySelectorController") as LINCountrySelectorController
        navigationController!.pushViewController(viewController, animated: true)
    }
}

extension LINPickNativeViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager!, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}

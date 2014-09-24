//
//  LINAboutMeController.swift
//  Lingua
//
//  Created by Hoang Ta on 9/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINAboutMeControllerDelegate {
    func controller(controller: LINAboutMeController, didUpdateInfo info: String)
}

class LINAboutMeController: LINViewController {
    @IBOutlet private weak var aboutMeTextView: UITextView!
    var delegate: LINAboutMeControllerDelegate?
    var aboutMe: String = "" {
        willSet(newAboutMe) {
            if aboutMeTextView != nil {
                aboutMeTextView.text = newAboutMe
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutMeTextView.text = aboutMe
        aboutMeTextView.becomeFirstResponder()
    }
    
    @IBAction func done(sender: UIButton) {
        delegate?.controller(self, didUpdateInfo: aboutMeTextView.text)
        navigationController?.popViewControllerAnimated(true)
    }
}

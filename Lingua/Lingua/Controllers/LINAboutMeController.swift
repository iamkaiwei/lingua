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
    @IBOutlet weak var aboutMe: UITextView!
    var delegate: LINAboutMeControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutMe.becomeFirstResponder()
    }
    
    @IBAction func done(sender: UIButton) {
        delegate?.controller(self, didUpdateInfo: aboutMe.text)
        navigationController?.popViewControllerAnimated(true)
    }
}

//
//  LINViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 7/3/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.setValue(UIFont.appLightFontWithSize(21), forKey: "font")
    }
}
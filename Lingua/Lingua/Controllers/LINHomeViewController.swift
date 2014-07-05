//
//  LINHomeViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINHomeViewController: LINViewController {

    @IBOutlet var titleLabel: UILabel
    @IBOutlet var profileButton: UIButton
    @IBOutlet var messageButton: UIButton
    @IBOutlet var teachButton: UIButton
    @IBOutlet var learnButton: UIButton
    @IBOutlet var tipLabel: UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = UIFont.appLightFontWithSize(22)
        tipLabel.textColor = UIColor.grayColor()
        tipLabel.font = UIFont.appLightFontWithSize(14)
    }

    @IBAction func openDrawer(sender: UIButton) {
        switch sender {
        case profileButton: mm_drawerController?.openDrawerSide(.Left, animated: true, completion: nil)
        case messageButton: mm_drawerController?.openDrawerSide(.Right, animated: true, completion: nil)
        default: break
        }
    }
    
    @IBAction func toggleOption(sender: UIButton) {
        if sender.selected {
            return
        }
        teachButton.selected = !teachButton.selected
        learnButton.selected = !learnButton.selected
    }

}

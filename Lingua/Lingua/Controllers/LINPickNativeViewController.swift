//
//  LINPickNativeViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickNativeViewController: UIViewController {

    @IBOutlet var languageLabel: UILabel
    @IBOutlet var languageLabel2: UILabel
    @IBOutlet var languageLabel3: UILabel
    @IBOutlet var saveButton: UIButton
    
    let languages = ["Chinese", "English"]
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func configureUI() {
        languageLabel.font = UIFont.appRegularFontWithSize(20)
        languageLabel2.font = UIFont.appRegularFontWithSize(17)
        languageLabel3.font = UIFont.appThinFontWithSize(14)
        saveButton.font = UIFont.appBoldFontWithSize(20)
    }
    
    @IBAction func togglePickerView(sender: UIButton) {
        if sender.titleForState(.Normal) == "Next" {
            let leftDrawer = storyboard.instantiateViewControllerWithIdentifier("kLINMyProfileViewController") as LINMyProfileViewController
            let center = storyboard.instantiateViewControllerWithIdentifier("kLINHomeViewController") as LINHomeViewController
            let rightDrawer = storyboard.instantiateViewControllerWithIdentifier("kLINFriendListViewController") as LINFriendListViewController
            
            let drawerController = MMDrawerController(centerViewController: center, leftDrawerViewController: leftDrawer, rightDrawerViewController: rightDrawer)
            drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
            drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView | MMOpenDrawerGestureMode.PanningNavigationBar
            navigationController?.pushViewController(drawerController, animated: true)
        }
    }
}


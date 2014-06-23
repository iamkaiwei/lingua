//
//  LINPickNativeViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickNativeViewController: UIViewController {

    @IBOutlet var pickerView: UIPickerView
    @IBOutlet var languageLabel: UILabel
    @IBOutlet var pickButton: UIButton

    let languages = ["Chinese", "English"]
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        pickerView.hidden = !pickerView.hidden
    }

}

extension LINPickNativeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return languages[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        languageLabel.text = languages[row]
        pickButton.setTitle("Next", forState: .Normal)
    }
}

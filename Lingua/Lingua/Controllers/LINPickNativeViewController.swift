//
//  LINPickNativeViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickNativeViewController: LINViewController {

    @IBOutlet var languageLabel: UILabel
    @IBOutlet var languageLabel2: UILabel
    @IBOutlet var languageLabel3: UILabel
    @IBOutlet var languagePickerView: UIView
    @IBOutlet var saveButton: UIButton
    @IBOutlet var textView: SZTextView
    
    var dropdown: REMenu {
        struct Static {
            static var instance: REMenu?
        }
        if Static.instance != nil {
            return Static.instance!
        }
    
        let languages = ["English", "Chinese"]
        var items = REMenuItem[]()
        for language in languages {
            let item = REMenuItem(title: language, image: nil, highlightedImage: nil, action: { menuItem in
                    self.languageLabel3.text = menuItem.title
                })
            item.tag = items.count
            items.append(item)
        }
        let menu = REMenu(items: items)
        menu.backgroundColor = UIColor.whiteColor()
        menu.font = UIFont.appThinFontWithSize(14)
        menu.textColor = UIColor.blackColor()
        menu.textOffset = CGSizeMake(-35, 0);
        menu.itemHeight = 40
        menu.textAlignment = .Right;
        menu.separatorColor = UIColor.appLightGrayColor()
        menu.borderWidth = 0;
        menu.highlightedBackgroundColor = UIColor.appTealColor()
        menu.shadowOpacity = 0.8
        menu.shadowRadius = 5
        Static.instance = menu
        return Static.instance!
            
    }
    
    func handleMenuItem(item: REMenuItem) {
        languageLabel3.text = item.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        languageLabel.font = UIFont.appRegularFontWithSize(20)
        languageLabel2.font = UIFont.appRegularFontWithSize(17)
        languageLabel3.font = UIFont.appThinFontWithSize(14)
        saveButton.font = UIFont.appBoldFontWithSize(20)
        textView.tintColor = UIColor.appTealColor()
        textView.font = UIFont.appLightFontWithSize(14)
        textView.placeholder = "Write an introduction about yourself in your native language. This will help other users find you."
        textView.placeholderTextColor = UIColor.grayColor()
        textView.layoutManager.delegate = self
        textView._placeholderTextView.layoutManager.delegate = self
    }
    
    @IBAction func saveUserInfo(sender: UIButton) {
        let leftDrawer = storyboard.instantiateViewControllerWithIdentifier("kLINMyProfileViewController") as LINMyProfileViewController
        let center = storyboard.instantiateViewControllerWithIdentifier("kLINHomeViewController") as LINHomeViewController
        let rightDrawer = storyboard.instantiateViewControllerWithIdentifier("kLINFriendListViewController") as LINFriendListViewController
        
        let drawerController = MMDrawerController(centerViewController: center, leftDrawerViewController: leftDrawer, rightDrawerViewController: rightDrawer)
        drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
        drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView | MMOpenDrawerGestureMode.PanningNavigationBar
        navigationController?.pushViewController(drawerController, animated: true)
    }

    @IBAction func toggleMenu(sender: UITapGestureRecognizer) {
        if dropdown.isOpen {
            dropdown.close()
        } else {
            var frame = languagePickerView.frame
            frame.origin.y += (frame.height + 2)
            frame.size.height *= CGFloat(dropdown.items.count + 1)
            dropdown.showFromRect(frame, inView: view)
        }
    }
}

extension LINPickNativeViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager!, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}

//
//  LINChatController.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/14/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation
import QuartzCore

class LINChatController: UIViewController {

    @IBOutlet var inputContainerView: UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputContainerView.layer.borderColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0).CGColor
        inputContainerView.layer.borderWidth = 0.5
    }
    
    @IBAction func backButtonTouched(sender: UIButton) {
        if navigationController {
            navigationController.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
       }
    }
}
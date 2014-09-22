//
//  LINEditProfileController.swift
//  Lingua
//
//  Created by Hoang Ta on 9/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINEditProfileController: LINViewController {
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

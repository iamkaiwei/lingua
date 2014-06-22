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
    
    let languages = ["Chinese", "English"]
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func togglePickerView(sender: UIButton) {
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
    }
}

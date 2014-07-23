//
//  LINHomeController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINHomeController: LINViewController {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var teachButton: UIButton!
    @IBOutlet weak var learnButton: UIButton!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var loadingView: LINLoadingView!
    
    var timer: NSTimer?
    let (quotes, authors) = LINResourceHelper.quotes()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tipLabel.textColor = UIColor.grayColor()
        tipLabel.font = UIFont.appLightFontWithSize(14)
        authorLabel.textColor = UIColor.grayColor()
        authorLabel.font = UIFont.appLightFontWithSize(14)
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "changeTip", userInfo: nil, repeats: true)
        showTip()
    }

    func showTip() {
        loadingView.hidden = false
        authorLabel.hidden = false
        timer?.fire()
    }
    
    func hideTip() {
        loadingView.hidden = true
        authorLabel.hidden = true
        timer?.invalidate()
    }
    
    func changeTip() {
        let index = arc4random_uniform(UInt32(quotes.count))
        tipLabel.text = quotes[Int(index)]
        authorLabel.text = authors[Int(index)]
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
        
        performSegueWithIdentifier("kLINChatControllerIdentifier", sender: self)
    }
}

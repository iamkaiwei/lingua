//
//  LINLoginView.swift
//  Lingua
//
//  Created by Hoang Ta on 6/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

enum LoginOptions {
    case Facebook, Google
}

protocol LINLoginViewDelegate {
    func loginView(loginView: LINLoginView, option didLoginWithOption: LoginOptions)
}

class LINLoginView: UIView {
    
    @IBOutlet var facebookLoginView: FBLoginView
    @IBOutlet var titleLabel: UILabel
    
    var delegate: LINLoginViewDelegate?
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(UINib(nibName: "LINLoginView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView)
        titleLabel.font = UIFont.appBoldFontWithSize(25)
    }
    
    
    @IBAction func loginWithGoogle(sender: UIButton) {
        delegate?.loginView(self, option: .Google)
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        delegate?.loginView(self, option: .Facebook)
    }
    
}

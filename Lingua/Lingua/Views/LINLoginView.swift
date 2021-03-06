//
//  LINLoginView.swift
//  Lingua
//  Updated by Kiet Nguyen on 7/7/2014.
//  Created by Hoang Ta on 6/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

enum LINLoginOptions {
    case Facebook, Google
}

protocol LINLoginViewDelegate {
    func loginView(loginView: LINLoginView, option didLoginWithOption: LINLoginOptions)
}

class LINLoginView: UIView {
    var delegate: LINLoginViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ frame: CGRect) {
        super.init(frame: frame)
        var contentView = UINib(nibName: "LINLoginView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
        contentView.frame = frame
        addSubview(contentView)
    }
    
    // MARK: Actions
    
    @IBAction func loginWithGoogle(sender: UIButton) {
        delegate?.loginView(self, option: .Google)
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        delegate?.loginView(self, option: .Facebook)
    }
}

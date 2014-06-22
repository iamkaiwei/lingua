//
//  LINLanguagePickingHeaderView.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINLanguagePickingHeaderViewDelegate {
    func didTapShow(header: LINLanguagePickingHeaderView)
}

class LINLanguagePickingHeaderView: UIView {

    @IBOutlet var title: UILabel
    
    class func totalSection() -> Int { return 3 }
    class func heightForHeader() -> CGFloat { return 50 }
    
    var delegate: LINLanguagePickingHeaderViewDelegate?
    var index = 0
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(UINib(nibName: "LINLanguagePickingHeaderView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView)
        title.text = ""
    }

    @IBAction func didTapShowButton(sender: UIButton) {
        delegate?.didTapShow(self)
    }
}

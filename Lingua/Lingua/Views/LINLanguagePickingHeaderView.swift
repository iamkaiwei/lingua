//
//  LINLanguagePickingHeaderView.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINLanguagePickingHeaderViewDelegate {
    func didTapHeader(header: LINLanguagePickingHeaderView)
}

class LINLanguagePickingHeaderView: UIView {

    @IBOutlet var titleLabel: UILabel
    @IBOutlet var bottomLine: UIView
    @IBOutlet var accessoryImage: UIImageView
    
    class func totalSection() -> Int { return 3 }
    class func heightForOpenHeader() -> CGFloat { return 50 }
    class func heightForClosedHeader() -> CGFloat { return 49 }
    
    var delegate: LINLanguagePickingHeaderViewDelegate?
    var index = 0
    var isExpanded: Bool = false {
        didSet {
            accessoryImage.transform = CGAffineTransformMakeRotation(isExpanded ? M_PI : 0)
        }
    }
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(UINib(nibName: "LINLanguagePickingHeaderView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView)
        titleLabel.text = ""
        titleLabel.font = UIFont.appRegularFontWithSize(17)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapHeader"))
    }

    func didTapHeader() {
        delegate?.didTapHeader(self)
        isExpanded = !isExpanded
    }
}

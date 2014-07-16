//
//  LINLanguagePickingHeaderView.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

enum ArrowDirection {
    case Up
    case Down
    case Left
    case Right
}

protocol LINLanguagePickingHeaderViewDelegate {
    func didTapHeader(header: LINLanguagePickingHeaderView)
}

class LINLanguagePickingHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var titleLabel: UILabel
    @IBOutlet var bottomLine: UIView
    @IBOutlet var accessoryImage: UIImageView
    
    class func totalSection() -> Int { return 3 }
    class func heightForOpenHeader() -> CGFloat { return 50 }
    class func heightForClosedHeader() -> CGFloat { return 49 }
    
    var delegate: LINLanguagePickingHeaderViewDelegate?
    var index = 0
    var accessoryDirection: ArrowDirection = .Down {
        didSet {
            switch accessoryDirection {
            case .Down: accessoryImage.transform = CGAffineTransformMakeRotation(0)
            case .Up: accessoryImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            case .Left: accessoryImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            case .Right: accessoryImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*1.5))
            default: break
            }
        }
    }
    
    var accessoryView: UIView! = nil {
        willSet {
            if accessoryView != nil {
                accessoryView.alpha = 0
                accessoryView.removeFromSuperview()
            }
        }
        didSet {
            accessoryView.frame =
                    CGRectMake(CGRectGetMinX(accessoryImage.frame) - CGRectGetWidth(accessoryView.frame) - 5, //5 for more padding
                    CGRectGetHeight(self.frame)/2 - CGRectGetHeight(accessoryView.frame)/2,
                    CGRectGetWidth(accessoryView.frame),
                    CGRectGetHeight(accessoryView.frame))
            if let label = accessoryView as? UILabel { //There should be a more generic way than this to set textAlignment
                label.textAlignment = .Right
            }
            addSubview(accessoryView)
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
        if accessoryDirection == .Down {
            accessoryDirection = .Up
        } else if accessoryDirection == .Up {
            accessoryDirection = .Down
        }
    }
}

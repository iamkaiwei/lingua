//
//  LINLanguagePickingHeaderView.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

enum LINArrowDirection {
    case Up
    case Down
    case Left
    case Right
}

enum LINAccessoryViewType {
    case None
    case Label
    case Image
}

protocol LINLanguagePickingHeaderViewDelegate {
    func didTapHeader(header: LINLanguagePickingHeaderView)
}

class LINLanguagePickingHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomLine: UIView!
    @IBOutlet weak var accessoryImage: UIImageView!
    
    class func totalSection() -> Int { return 3 }
    class func heightForOpenHeader() -> CGFloat { return 50 }
    class func heightForClosedHeader() -> CGFloat { return 49 }
    
    var delegate: LINLanguagePickingHeaderViewDelegate?
    var index = 0
    var accessoryDirection: LINArrowDirection = .Down {
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
    
    private var accessoryView: UIView?
    var accessoryViewType: LINAccessoryViewType = .None {
        willSet(type) {
            accessoryView?.removeFromSuperview()
            switch type {
            case .Label:
                let label = UILabel()
                label.font = UIFont.appLightFontWithSize(14)
                label.textAlignment = .Right
                accessoryView = label
                
            case .Image:
                accessoryView = UIImageView()
            default: return
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

    func updateAccessoryViewWith(data: AnyObject) {
        if (data is String && accessoryViewType == .Label) || (data is UIImage && accessoryViewType == .Image) {
            if data is String {
                let label = accessoryView as UILabel
                label.text = data as String
                label.sizeToFit()
            } else {
                let imageView = accessoryView as UIImageView
                imageView.image = data as UIImage
                imageView.frame = CGRect(origin: CGPointZero, size: imageView.image.size)
            }
            
            let origin = CGPointMake(CGRectGetMinX(accessoryImage.frame) - CGRectGetWidth(accessoryView!.frame) - 5, CGRectGetHeight(self.frame)/2 - CGRectGetHeight(accessoryView!.frame)/2)
            accessoryView!.frame = CGRect(origin: origin, size: accessoryView!.frame.size)
        }
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

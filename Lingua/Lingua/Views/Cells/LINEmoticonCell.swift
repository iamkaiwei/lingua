//
//  LINEmoticonCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/10/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

let kLINEmoticonsViewCancelButtonIndex = 4

class LINEmoticonCell: UICollectionViewCell {
    var emoticonImgView = UIImageView()
    var cancelImgView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        emoticonImgView.removeFromSuperview()
        cancelImgView.removeFromSuperview()
    }
    
    func configureAtIndexPath(indexPath: NSIndexPath) {
        if indexPath.row == kLINEmoticonsViewCancelButtonIndex {
            let cancelImage = UIImage(named: "icn_cancel")
            cancelImgView.image = cancelImage
            cancelImgView.frame = CGRectMake(CGRectGetWidth(bounds)/2 - 13,
                                             CGRectGetHeight(bounds)/2 - cancelImage.size.height/2,
                                             cancelImage.size.width, cancelImage.size.height)
            addSubview(cancelImgView)
        } else {
            var row = indexPath.row
            if indexPath.row < kLINEmoticonsViewCancelButtonIndex {
                row += 1
            }
            emoticonImgView.frame = bounds
            emoticonImgView.image = UIImage(named: "emoticon_\(row)")
            addSubview(emoticonImgView)
        }
    }
}

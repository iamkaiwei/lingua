//
//  LINMyProfileViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINMyProfileViewController: LINViewController {

    @IBOutlet var nameLabel: UILabel
    @IBOutlet var proficiencyImageView: UIImageView
    @IBOutlet var avatarImageView: UIImageView
    @IBOutlet var collectionView: UICollectionView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.font = UIFont.appRegularFontWithSize(17)
        avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.frame)/2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }
}

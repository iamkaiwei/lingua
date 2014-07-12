//
//  LINMyProfileController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINMyProfileController: LINViewController {

    @IBOutlet var nameLabel: UILabel
    @IBOutlet var proficiencyImageView: UIImageView
    @IBOutlet var avatarImageView: UIImageView
    @IBOutlet var collectionView: UICollectionView
    
    var headerTitles = ["Teacher Badges", "Learner Badges", "\"Teach 5 more users to level up\""]
    var headerColors = [UIColor.appTealColor(), UIColor.appRedColor(), UIColor.grayColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.font = UIFont.appRegularFontWithSize(17)
        avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.frame)/2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor

        collectionView.registerClass(LINBadgeCell.self, forCellWithReuseIdentifier: "BadgeCellIdentifier")
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BadgeHeaderIdentifier")
    }
}

extension LINMyProfileController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if section == 2{
            return 0
        }
        return 10
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BadgeCellIdentifier", forIndexPath: indexPath) as LINBadgeCell
        if indexPath.section == 1 {
            cell.imageView.image = UIImage(named: "LearningBadge")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, viewForSupplementaryElementOfKind kind: String!, atIndexPath indexPath: NSIndexPath!) -> UICollectionReusableView! {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "BadgeHeaderIdentifier", forIndexPath: indexPath) as UICollectionReusableView
        let label = UILabel()
        label.font = UIFont.appRegularFontWithSize(14)
        label.textColor = headerColors[indexPath.section]
        label.text = headerTitles[indexPath.section]
        label.frame = headerView.bounds
        headerView.addSubview(label)
        return headerView
    }
}

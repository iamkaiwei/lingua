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
    @IBOutlet var introductionView: LINIntroductionView
    @IBOutlet var collectionViewTopSpaceConstraint: NSLayoutConstraint
    
    var headerTitles = ["Teacher Badges", "Learner Badges", "\"Teach 5 more users to level up\""]
    var headerColors = [UIColor.appTealColor(), UIColor.appRedColor(), UIColor.grayColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameLabel.font = UIFont.appRegularFontWithSize(17)
        avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.frame)/2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        introductionView.delegate = self;
        introductionView.introduction = "This is a very long intro duction This is a very long introduct This is a very long introduct"
        
        collectionView.registerClass(LINBadgeCell.self, forCellWithReuseIdentifier: "BadgeCellIdentifier")
        collectionView.registerClass(LINBadgeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BadgeHeaderIdentifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setNeedsUpdateConstraints()
    }
    
    @IBAction func editProfile(sender: UIButton) {
        
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
        } else {
            cell.imageView.image = UIImage(named: "TeachingBadge")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, viewForSupplementaryElementOfKind kind: String!, atIndexPath indexPath: NSIndexPath!) -> UICollectionReusableView! {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "BadgeHeaderIdentifier", forIndexPath: indexPath) as LINBadgeHeaderView
        headerView.titleLabel.textColor = headerColors[indexPath.section]
        headerView.titleLabel.text = headerTitles[indexPath.section]
        return headerView
    }
}

extension LINMyProfileController: LINIntroductionViewDelegate {
    
    func introductionView(introductionView: LINIntroductionView, didChangeToHeight height: CGFloat) {
        let padding: CGFloat = 20
        collectionViewTopSpaceConstraint.constant = height + padding
    }
}

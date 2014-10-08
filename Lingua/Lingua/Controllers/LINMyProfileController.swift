//
//  LINMyProfileController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINMyProfileController: LINViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proficiencyImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var introductionView: LINIntroductionView!
    @IBOutlet weak var collectionViewTopSpaceConstraint: NSLayoutConstraint!
    
    private var headerTitles = ["\"Teach 5 more users to level up\"", "Teacher Badges", "Learner Badges"]
    private var headerColors = [UIColor.grayColor(), UIColor.appTealColor(), UIColor.appRedColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let me = LINUserManager.sharedInstance.currentUser
        
        //User name
        nameLabel.font = UIFont.appRegularFontWithSize(17)
        nameLabel.text = me?.firstName
        
        //User profile picture
        avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.frame)/2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        if let url = me?.avatarURL {
            avatarImageView.sd_setImageWithURL(NSURL(string: url),
                placeholderImage: avatarImageView.image) {
                    (image, error, cacheType, imageURL) in
                    if let tmpImage = image {
                        self.avatarImageView.image = tmpImage
                    }
            }
        }
        
        //User about
        introductionView.delegate = self;
        if let introduction = me?.introduction {
            introductionView.introduction = introduction
        }
        
        //User average proficiency (writing and speaking)
        let meSpeakingProficiency = me?.speakingProficiency?.value ?? 1
        let meWritingProficiency = me?.writingProficiency?.value ?? 1
        let averageProficiency: Int = (meSpeakingProficiency + meWritingProficiency)/2.0 + 0.5
        let imageNames = ["Proficiency0", "Proficiency1", "Proficiency2", "Proficiency3", "Proficiency4"]
        if averageProficiency <= imageNames.count {
            proficiencyImageView.image = UIImage(named: imageNames[averageProficiency])
        }
        
        collectionView.registerClass(LINBadgeCell.self, forCellWithReuseIdentifier: "BadgeCellIdentifier")
        collectionView.registerClass(LINBadgeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BadgeHeaderIdentifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setNeedsUpdateConstraints()
    }
    
    @IBAction func editProfile(sender: UIButton) {
        let editProfileVC = storyboard!.instantiateViewControllerWithIdentifier("kLINEditProfileController") as LINEditProfileController
        let navigationController = UINavigationController(rootViewController: editProfileVC)
        navigationController.navigationBarHidden = true
        navigationController.transitioningDelegate = self
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

extension LINMyProfileController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BadgeCellIdentifier", forIndexPath: indexPath) as LINBadgeCell
        if indexPath.section == 1 {
            cell.imageView.image = UIImage(named: "TeachingBadge")
        } else {
            cell.imageView.image = UIImage(named: "LearningBadge")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "BadgeHeaderIdentifier", forIndexPath: indexPath) as LINBadgeHeaderView
        headerView.titleLabel.textColor = headerColors[indexPath.section]
        headerView.titleLabel.text = headerTitles[indexPath.section]
        return headerView
    }
}

extension LINMyProfileController: LINIntroductionViewDelegate {
    
    func introductionView(introductionView: LINIntroductionView, didChangeToHeight height: CGFloat) {
        let padding: CGFloat = 20
        
        if UIDevice.currentDevice().model != "iPhone Simulator" {
            let frame = CGRectMake(0, CGRectGetMaxY(introductionView.frame) + padding, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(introductionView.frame) - padding)
            collectionView.frame = frame
            return
        }
        
        collectionViewTopSpaceConstraint.constant = height + padding
    }
}

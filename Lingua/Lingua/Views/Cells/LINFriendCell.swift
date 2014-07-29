//
//  LINFriendCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/13/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation
import UIKit

class LINFriendCell: UITableViewCell {
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureCellWithUserData(user: LINUser) {
        nameLabel.text = user.firstName
        
        // set avatar
        avatarImgView.sd_setImageWithURL(NSURL(fileURLWithPath: user.avatarURL))
        avatarImgView.layer.cornerRadius = 20.0
        avatarImgView.layer.masksToBounds = true
    }
}
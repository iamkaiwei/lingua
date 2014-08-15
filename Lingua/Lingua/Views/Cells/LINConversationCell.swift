//
//  LINConversationCell.swift
//  Lingua
//
//  Created by TaiVuong on 8/13/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINConversationCell: UITableViewCell {
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureWithConversation(conversation:LINConversation) {
        var opponentDetail = conversation.getOpponentDetail()
        nameLabel.text = opponentDetail.firstName
        roleName.text = opponentDetail.role
        // set avatar
        avatarImgView.sd_setImageWithURL(NSURL(string: opponentDetail.avatar),
            placeholderImage: UIImage(named: "avatar_holder"))
        avatarImgView.addRoundedCorner()
        
        // set conversation date
        var conversationDate : NSDate? = nil
        
        if let tempDate = NSDateFormatter.iSODateFormatter().dateFromString(conversation.lastestUpdate) {
            conversationDate = tempDate as NSDate
        }
        
        dateLabel.text = NSDateFormatter.getConversationTimeStringFromDate(conversationDate!)
        
        //check if conversation has new message
        var lastOnline:NSDate? = LINStorageHelper.getLastOnlineTimeStamp()
        if lastOnline == nil {
            //We have no previous online timestamp
            self.backgroundColor = UIColor.lightGrayColor()
        }
        else
        {
            if lastOnline?.compare(conversationDate) == NSComparisonResult.OrderedAscending {
                self.backgroundColor = UIColor.lightGrayColor()
            }
            else
            {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
}
//
//  BubbleCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class BubbleCell: UITableViewCell {
    
    var customView: UIView = UIView()
    var bubbleImageView: UIImageView = UIImageView()
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None
        contentView.addSubview(bubbleImageView)
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
    }
    
    func configureCellWithBubbleData(bubbleData: BubbleData) {
        let type = bubbleData.type
        let bubbleSize = bubbleData.view.frame.size
    
        var offsetX = (type == BubbleType.SomeoneElse ? 5 : frame.size.width  - bubbleSize.width - bubbleData.insets.left - bubbleData.insets.right - 5)
        
        customView.removeFromSuperview()
        
        customView = bubbleData.view
        customView.frame = CGRect(x: offsetX + bubbleData.insets.left - (type == BubbleType.SomeoneElse ? 2 : 0),
                                  y: bubbleData.insets.top + 5,
                                  width: bubbleSize.width,
                                  height: bubbleSize.height)
        contentView.addSubview(customView)
        
        if type == BubbleType.SomeoneElse {
            bubbleImageView.image = UIImage(named: "Chat_bubble_receiver").resizableImageWithCapInsets(UIEdgeInsetsMake(14, 21, 14, 21))  // Box_chat_right
        } else {
            bubbleImageView.image = UIImage(named: "Chat_bubble_sender").resizableImageWithCapInsets(UIEdgeInsetsMake(14, 15, 14, 15)) // Box_chat_left
        }
        
        // FIXME
        bubbleImageView.frame = CGRect(x: offsetX + 0,
                                       y: 5,
                                      width: bubbleSize.width + bubbleData.insets.left + bubbleData.insets.right,
                                      height: bubbleSize.height + bubbleData.insets.top + bubbleData.insets.bottom)
        
        // FIXME
        // Add time create
       //  offsetX = (type == BubbleType.SomeoneElse ? (customView.frame.origin.x + customView.frame.size.width + 20) : (customView.frame.origin.x - 60))
        let createAtLabel = UILabel(frame: CGRect(x: offsetX,
                                                  y: customView.frame.origin.y + customView.frame.size.height/2 - 10,
                                                  width: 100, height: 20))
        createAtLabel.text = "10:56 pm"
        createAtLabel.font = UIFont.appRegularFontWithSize(10)
        createAtLabel.textColor =  UIColor.lightGrayColor()
        
        contentView.addSubview(createAtLabel)
    }
}
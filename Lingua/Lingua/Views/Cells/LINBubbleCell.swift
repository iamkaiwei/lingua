//
//  BubbleCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

let kBubbleMaxWidth = 233
let kBubbleMaxHeight = 9999

class LINBubbleCell: UITableViewCell {
    var contentLabel: UILabel = UILabel()
    var bubbleImageView: UIImageView = UIImageView()
    var createAtLabel: UILabel = UILabel()

    let textInsetsMine = UIEdgeInsetsMake(5, 10, 7, 17)
    let textInsetsSomeone = UIEdgeInsetsMake(5, 15, 7, 10)
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        
        // Bubble imageview
        contentView.addSubview(bubbleImageView)
        
        // Content label
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.appRegularFontWithSize(14)
        addSubview(contentLabel)
        
        // CreateAt label
        createAtLabel.font = UIFont.appRegularFontWithSize(10)
        createAtLabel.textColor =  UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
        addSubview(createAtLabel)
    }
    
    func configureCellWithMessageData(messageData: LINMessage) {
        // Content label
        let rect = LINBubbleCell.getboundingRectWithText(messageData.text, font: contentLabel.font)
        
        let insets = (messageData.incoming == false ? textInsetsMine : textInsetsSomeone)
        let offsetX = (messageData.incoming == true ? 5 : frame.size.width  - rect.size.width - insets.left - insets.right - 5)
        
        contentLabel.frame = CGRect(x: offsetX + insets.left - (messageData.incoming == true ? 6 : 0),
                                    y: insets.top + 15,
                                width: rect.size.width,
                               height: rect.size.height)
        contentLabel.text = messageData.text
        
        // Bubble imageview
        let bubbleCapInsets = UIEdgeInsetsMake(20, 10, 10, 10)
        if messageData.incoming {
            bubbleImageView.image = UIImage(named: "ChatBoxLeft").resizableImageWithCapInsets(bubbleCapInsets)
        } else {
            bubbleImageView.image = UIImage(named: "ChatBoxRight").resizableImageWithCapInsets(bubbleCapInsets)
        }
        
        bubbleImageView.frame = CGRect(x: offsetX + 0,
                                       y: 5,
                                   width: rect.size.width + insets.left + insets.right - 5,
                                  height: CGRectGetHeight(rect) + 20)
        
        // CreateAt label
        let contentFrame = contentLabel.frame
        let offsetXCreateAtLabel = (messageData.incoming == true ? (contentFrame.origin.x + contentFrame.size.width + 20) :
                                                                                            (contentFrame.origin.x - 60))
        createAtLabel.frame = CGRect(x: offsetXCreateAtLabel,
                                     y: contentFrame.origin.y + contentFrame.size.height/2 - 10,
                                 width: 100,
                                height: 20)
        createAtLabel.text = NSDateFormatter.hourStringFromDate(messageData.sendDate)
    }
    
    class func getHeighWithMessageData(messageData: LINMessage)-> CGFloat {
        let rect = getboundingRectWithText(messageData.text, font: UIFont.appRegularFontWithSize(14))
        return CGRectGetHeight(rect) + 20
    }
    
    // MARK: Utils
    
    class func getboundingRectWithText(text: String, font: UIFont) -> CGRect {
        return (text as NSString).boundingRectWithSize(CGSize(width: kBubbleMaxWidth, height: kBubbleMaxHeight),
                                                            options: .UsesLineFragmentOrigin,
                                                         attributes: [NSFontAttributeName: font],
                                                            context: nil)
    }
}
//
//  BubbleCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

let kTextMessageMaxWidth = 233
let kTextMessageMaxHeight = 9999
let kPhotoMessageMaxWidth = 200
let kPhotoMessageMaxHeight = 200

enum MessageType: Int {
    case Text = 1, Photo, Voice
    func getSubtitleWithText(text: String) -> String {
        var result = ""
        switch self {
            case .Text:
                result = text
            case .Photo:
                result = "Sent you a photo"
            case .Voice:
                result = "Sent you a voice message"
            default:
                break
        }
        return result
    }
}

class LINBubbleCell: UITableViewCell {
    var contentLabel: UILabel = UILabel()
    var bubbleImageView: UIImageView = UIImageView()
    var createAtLabel: UILabel = UILabel()
    var photoImgView: UIImageView = UIImageView()
    
    let textInsetsMine = UIEdgeInsetsMake(5, 10, 7, 17)
    let textInsetsSomeone = UIEdgeInsetsMake(5, 15, 7, 10)
    let photoInsetsMine = UIEdgeInsetsMake(10, 10, 18, 10)
    let photoInsetsSomeone = UIEdgeInsetsMake(10, 10, 10, 10)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        
        // Bubble imageview
        addSubview(bubbleImageView)
        
        // Content label
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.appRegularFontWithSize(14)
        
        // CreateAt label
        createAtLabel.font = UIFont.appRegularFontWithSize(10)
        createAtLabel.textColor =  UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
        addSubview(createAtLabel)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    func configureCellWithMessageData(messageData: LINMessage) {
        contentLabel.removeFromSuperview()
        photoImgView.removeFromSuperview()
        
        switch(messageData.type) {
            case .Text:
                configureWithTextMessage(messageData)
            case .Photo:
                configureWithPhotoMessage(messageData)
            default:
                break
        }
    }
    
    // MARK: Send texts, photos, voices message
    
    private func configureWithTextMessage(messageData: LINMessage) {
        // Content label
        let rect = LINBubbleCell.getboundingRectWithText(messageData.text, font: contentLabel.font)
        
        let insets = (messageData.incoming == false ? textInsetsMine : textInsetsSomeone)
        let offsetX = (messageData.incoming == true ? 5 : frame.size.width  - rect.size.width - insets.left - insets.right - 5)
        
        contentLabel.frame = CGRect(x: offsetX + insets.left - (messageData.incoming == true ? 6 : 0),
                                    y: insets.top + 15,
                                width: rect.size.width,
                               height: rect.size.height)
        contentLabel.text = messageData.text
        addSubview(contentLabel)
        
        // Bubble imageview
        bubbleImageView.frame = CGRect(x: offsetX,
                                       y: 5,
                                   width: rect.size.width + insets.left + insets.right - 5,
                                  height: CGRectGetHeight(rect) + 20)
        
         calcTimeFrameWithContentFrame(contentLabel.frame, messageData: messageData)
    }
    
    private func configureWithPhotoMessage(messageData: LINMessage) {
        if messageData.photo == nil {
            println("Downloading photo message.")
            // Add photo to cell by image URL
            photoImgView.sd_setImageWithURL(NSURL(string: messageData.text)) {
              (image, error, cacheType, imageURL) in
                if let tmpImage = image {
                    println("Finish downloading photo message.")
                    messageData.photo = tmpImage
                    self.addPhotoToBubbleCellWithMessageData(messageData)
                    
                    // Save photo to camera roll
                    UIImageWriteToSavedPhotosAlbum(tmpImage, nil, nil, nil)
                }
            }
        } else {
            // Add photo to cell by image
            self.addPhotoToBubbleCellWithMessageData(messageData)
        }
    }
    
    private func addPhotoToBubbleCellWithMessageData(messageData: LINMessage) {
        var imageSize = messageData.photo!.size
        if Int(imageSize.width) > kPhotoMessageMaxWidth {
            imageSize.height /= CGFloat(Int(imageSize.width) / kPhotoMessageMaxWidth)
            imageSize.width = CGFloat(kPhotoMessageMaxWidth)
        }
        
        println("Photo size: width: \(imageSize.width) height: \(imageSize.height)")
        
        photoImgView.image = messageData.photo!
        photoImgView.layer.cornerRadius = 5.0
        photoImgView.layer.masksToBounds = true
        
        let insets = (messageData.incoming == false ? photoInsetsMine : photoInsetsSomeone)
        let offsetX = (messageData.incoming == true ? 5 : frame.size.width  - imageSize.width - insets.left - insets.right - 5)
        
        photoImgView.frame = CGRect(x: offsetX + insets.left,
            y: insets.top + 10,
            width: imageSize.width,
            height: imageSize.height)
        addSubview(photoImgView)
        
        // Bubble imageview
        bubbleImageView.frame = CGRect(x: offsetX + 0,
            y: 0,
            width: imageSize.width + insets.left + insets.right,
            height: imageSize.height + insets.top + insets.bottom + (messageData.incoming == true ? 10: 0))
        
        calcTimeFrameWithContentFrame(bubbleImageView.frame, messageData: messageData)
    }
    
    private func calcTimeFrameWithContentFrame(contentFrame: CGRect, messageData: LINMessage) {
        // Bubble imageview
        let bubbleCapInsets = UIEdgeInsetsMake(20, 10, 10, 10)
        if messageData.incoming {
            bubbleImageView.image = UIImage(named: "ChatBoxLeft").resizableImageWithCapInsets(bubbleCapInsets)
        } else {
            bubbleImageView.image = UIImage(named: "ChatBoxRight").resizableImageWithCapInsets(bubbleCapInsets)
        }
        
        // Time label
        let contentFrame = contentFrame
        let offsetXCreateAtLabel = (messageData.incoming == true ? (contentFrame.origin.x + contentFrame.size.width + 20) :
            (contentFrame.origin.x - 60))
        createAtLabel.frame = CGRect(x: offsetXCreateAtLabel,
                                     y: contentFrame.origin.y + contentFrame.size.height / 2 - 10,
                                 width: 100,
                                height: 20)
        createAtLabel.text = NSDateFormatter.hourStringFromDate(messageData.sendDate)
    }
    
    class func getHeighWithMessageData(messageData: LINMessage)-> CGFloat {
        var height: CGFloat = 0.0
        
        switch(messageData.type) {
            case .Text:
                let rect = getboundingRectWithText(messageData.text, font: UIFont.appRegularFontWithSize(14))
                height =  CGRectGetHeight(rect) + 20
            case .Photo:
                if let tmpPhoto = messageData.photo {
                    let imageSize = tmpPhoto.size
                    height = imageSize.height / (CGFloat(Int(imageSize.width) / kPhotoMessageMaxWidth)) + 30
                } else {
                    height = CGFloat(kPhotoMessageMaxHeight)
                }
            default:
               break
        }
        
        return height
    }
    
    // MARK: Utils
    
    class func getboundingRectWithText(text: String, font: UIFont) -> CGRect {
        return (text as NSString).boundingRectWithSize(CGSize(width: kTextMessageMaxWidth, height: kTextMessageMaxHeight),
                                                            options: .UsesLineFragmentOrigin,
                                                         attributes: [NSFontAttributeName: font],
                                                            context: nil)
    }
}
//
//  BubbleCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation


let kLINTextMessageMaxHeight: CGFloat = 9999
let kLINVoiceMessageMaxHeight: CGFloat = 55
let kLINTimeLabelMaxWidth: CGFloat = 100
let kLINTimeLabelMaxHeight: CGFloat = 20

let kLINSideMargin: CGFloat = 10
let kLINTextCellHeightPadding: CGFloat = 5
let kLINPhotoCellHeightPadding: CGFloat = 30

// Resend message
let kLINResendButtonWidth: CGFloat = 20
let kLINResendButtonHeight: CGFloat = 20

protocol LINBubbleCellDelegate {
    func bubbleCellDidStartPlayingRecord(bubbleCell: LINBubbleCell)
    func bubbleCellDidStartResendMessage(bubbleCell: LINBubbleCell)
    func bubbleCellDidOpenPhotoPreview(bubbleCell: LINBubbleCell)
}

class LINBubbleCell: UITableViewCell {
    private var contentTextView = UITextView()
    private var bubbleImageView = UIImageView()
    private var createAtLabel = UILabel()
    private var photoImgView = UIImageView()
    private let placeholderImage = UIImage(named: "placeholder")
    
    // Message status
    private var overlayView = UIImageView()
    private var resendButton: UIButton?
    
    //Voice message
    private var playButton: UIButton?
    private var voiceProgressBar: UIProgressView?
    private var durationLabel: UILabel?

    private let textInsetsMine = UIEdgeInsetsMake(5, 10, 7, 17)
    private let textInsetsSomeone = UIEdgeInsetsMake(5, 15, 7, 10)
    private let resendButtonInsets = UIEdgeInsetsMake(0, 5, 0, 5)
    
    var delegate: LINBubbleCellDelegate?
    
    // Textkit
    private var emoticonsTextStorage = LINParsingEmoticonsTextStorage()

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        clipsToBounds = true
        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        
        // Enable touch event to photo imageview
        photoImgView.userInteractionEnabled = true

        // Bubble imageview
        addSubview(bubbleImageView)
        
        // Content
        contentTextView.userInteractionEnabled = false
        contentTextView.scrollEnabled = false
        contentTextView.editable = false
        contentTextView.backgroundColor = UIColor.clearColor()
        contentTextView.font = UIFont.appRegularFontWithSize(14)
        
        // CreateAt label
        createAtLabel.font = UIFont.appRegularFontWithSize(8)
        createAtLabel.textColor =  UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
        addSubview(createAtLabel)

        emoticonsTextStorage.addLayoutManager(contentTextView.layoutManager)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        contentTextView.removeFromSuperview()
        photoImgView.removeFromSuperview()
        playButton?.removeFromSuperview()
        voiceProgressBar?.removeFromSuperview()
        durationLabel?.removeFromSuperview()
        overlayView.removeFromSuperview()
        resendButton?.removeFromSuperview()
        
        if let playerDelegate = LINAudioHelper.sharedInstance.playerDelegate as? LINBubbleCell {
            if playerDelegate == self {
                LINAudioHelper.sharedInstance.playerDelegate = nil
            }
        }
    }

    func configureCellWithMessage(message: LINMessage) {
        switch(message.type) {
            case .Text:
                configureWithTextMessage(message)
            case .Photo:
                configureWithPhotoMessage(message)
            case .Voice:
                configureWithVoiceMessage(message)
            default:
                break
        }
    }
    
    // MARK: Send texts, photos, voices message
    
    private func configureWithTextMessage(message: LINMessage) {
        emoticonsTextStorage.setAttributedString(NSAttributedString(string: message.content as String))
        
        let size = contentTextView.sizeThatFits(CGSize(width: LINBubbleCell.maxWidthOfMessage(), height: kLINTextMessageMaxHeight))
        let insets = (message.incoming == false ? textInsetsMine : textInsetsSomeone)
        let offsetX = (message.incoming == true ? 0 : UIScreen.mainScreen().bounds.size.width - size.width - insets.left - insets.right)
        
        contentTextView.frame = CGRectMake(offsetX + insets.left, insets.top, size.width, size.height)
        addSubview(contentTextView)
        
        // Bubble imageview
        bubbleImageView.frame = CGRect(x: contentTextView.frame.origin.x - 5, y: 0,
                                       width: contentTextView.frame.size.width + 10,
                                       height: contentTextView.frame.size.height)
        
        addOtherViewsToBubbleCellWithMessage(message)
    }
    
    private func configureWithPhotoMessage(message: LINMessage) {
        if (message.content == nil && message.url != nil) ||
           (message.content != nil && !message.downloaded && message.url != nil) {
            
            // Resize place holder image
            let newSize = CGSize.getSizeFromImageURL(message.url! as String).scaledSize()
            message.content = placeholderImage!.resizableImageWithNewSize(newSize)
            addPhotoToBubbleCellWithMessage(message)

            // Add photo to cell by image URL
            photoImgView.sd_setImageWithURL(NSURL(string: message.url!),
                                            placeholderImage: placeholderImage) {
              (image, error, cacheType, imageURL) in
                if error != nil {
                    println("Download image has some errors \(error!.description)")
                    return
                }

                message.downloaded = true
                message.content = image
            }
        } else {
            // Add photo to cell by image
            message.downloaded = true
            self.addPhotoToBubbleCellWithMessage(message)
        }
    }
    
    private func configureWithVoiceMessage(message: LINMessage) {
        if message.content == nil && message.url != nil {
            LINNetworkClient.sharedInstance.downloadFile(message.url!, completion: { (data, error) in
                if data != nil {
                    println("Downloaded voice record successfully")
                    message.content = data
                    message.duration = LINAudioHelper.sharedInstance.getDurationFromData(data!)
                    let simplified = Int(message.duration + 0.5)
                    self.durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
                }
            })
        }

        let voiceMessageMaxWidth = LINBubbleCell.maxWidthOfMessage()
        let x = message.incoming == true ? kLINSideMargin : UIScreen.mainScreen().bounds.size.width - voiceMessageMaxWidth - kLINSideMargin/2
        
        // Set up other UIs
        playButton = UIButton(frame: CGRectMake(x, 5, kLINVoiceMessageMaxHeight, kLINVoiceMessageMaxHeight))
        playButton?.setImage(UIImage(named: "PlayButton"), forState: .Normal)
        playButton?.setImage(UIImage(named: "PauseButton"), forState: .Selected)
        playButton?.addTarget(self, action: "toggleAudioButton:", forControlEvents: .TouchUpInside)
        addSubview(playButton!)
        
        voiceProgressBar = UIProgressView(frame: CGRectMake(CGRectGetMaxX(playButton!.frame) - 7, kLINVoiceMessageMaxHeight/2 + kLINSideMargin - 7, voiceMessageMaxWidth - CGRectGetWidth(playButton!.frame)*2, 2))
        voiceProgressBar?.progressTintColor = UIColor.appTealColor()
        voiceProgressBar?.trackTintColor = UIColor.lightGrayColor()
        addSubview(voiceProgressBar!)
        
        durationLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(voiceProgressBar!.frame) + kLINSideMargin, kLINVoiceMessageMaxHeight/2 - kLINSideMargin/2, 50, 20))
        durationLabel?.font = UIFont.appLightFontWithSize(14)
        let simplified = Int(message.duration + 0.5)
        durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
        durationLabel?.numberOfLines = 0
        addSubview(durationLabel!)
        
        // Bubble imageview
        bubbleImageView.frame = CGRectMake(x, 0,  voiceMessageMaxWidth - 7,  kLINVoiceMessageMaxHeight - 5)
        addOtherViewsToBubbleCellWithMessage(message)
    }
    
    private func addPhotoToBubbleCellWithMessage(message: LINMessage) {
        var imageSize = (message.content as UIImage).size.scaledSize()

        photoImgView.image = message.content as? UIImage
        photoImgView.layer.cornerRadius = 5.0
        photoImgView.layer.masksToBounds = true
        
        let insets = (message.incoming == false ? textInsetsMine : textInsetsSomeone)
        let offsetX = (message.incoming == true ? 0 : UIScreen.mainScreen().bounds.size.width - imageSize.width - insets.left - insets.right - 5)
        
        photoImgView.frame = CGRect(x: offsetX + insets.left + (message.incoming == true ? 3 : 4),
                                    y: insets.top + 15,
                                    width: imageSize.width,
                                    height: imageSize.height)
        addSubview(photoImgView)

        // Bubble imageview
        bubbleImageView.frame = CGRect(x: offsetX + insets.left - 5,
                                       y: 0,
                                       width: imageSize.width + 17,
                                       height: imageSize.height + 28)
        
        addOtherViewsToBubbleCellWithMessage(message)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("openPhotoPreviewWithGesture:"))
        photoImgView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func addOtherViewsToBubbleCellWithMessage(message: LINMessage) {
        addOverlayViewWithMessage(message)
        addBubbleViewWithMessage(message)
        addTimeViewWithMessage(message)
        addResendButtonWithMessage(message)
    }
    
    private func addBubbleViewWithMessage(message: LINMessage) {
        var boxImgName: String?
        if message.incoming {
            boxImgName = (message.state == LINMessageState.UnSent ? "box_resend_left" : "ChatBoxLeft")
        } else {
            boxImgName = (message.state == LINMessageState.UnSent ? "box_resend_right" : "ChatBoxRight")
        }
        
        bubbleImageView.image = UIImage(named: boxImgName!)
    }
    
    private func addTimeViewWithMessage(message: LINMessage) {
        let timeValue = NSDateFormatter.hourDateFormatter().stringFromDate(message.sendDate).lowercaseString
        
        // Size for time value
        let bubbleViewFrame = bubbleImageView.frame
        let delta: CGFloat = (message.state == LINMessageState.UnSent ? (resendButtonInsets.right + kLINResendButtonWidth) : 0)
        let sizeTimeLabel = (timeValue as NSString).boundingRectWithSize(CGSizeMake(kLINTimeLabelMaxWidth, kLINTimeLabelMaxHeight), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: createAtLabel.font], context: nil).size
        
        // (x, y) for time label
        let offsetX = (message.incoming == true ? (bubbleViewFrame.origin.x + bubbleViewFrame.size.width + resendButtonInsets.right + delta) : (bubbleViewFrame.origin.x - (5 + sizeTimeLabel.width + delta)))
        let offsetY = bubbleViewFrame.origin.y + bubbleViewFrame.size.height / 2 - resendButtonInsets.right
        
        createAtLabel.frame = CGRect(x: offsetX, y: offsetY, width: sizeTimeLabel.width, height: kLINTimeLabelMaxHeight)
        createAtLabel.text = timeValue
    }
    
    private func addResendButtonWithMessage(message: LINMessage) {
        if message.state == LINMessageState.UnSent {
            let bubbleViewFrame = bubbleImageView.frame
            let offsetX = (message.incoming == true ? (bubbleViewFrame.origin.x + bubbleViewFrame.size.width + resendButtonInsets.right) : (bubbleViewFrame.origin.x - (resendButtonInsets.right + kLINResendButtonWidth)))
            let offsetY = createAtLabel.frame.origin.y
            
            resendButton?.removeFromSuperview()
            resendButton = UIButton(frame: CGRectMake(offsetX, offsetY, kLINResendButtonWidth, kLINResendButtonHeight))
            resendButton?.setImage(UIImage(named: "icn_resend"), forState: .Normal)
            resendButton?.addTarget(self, action: "resendButtonTouched:", forControlEvents: .TouchUpInside)
            addSubview(resendButton!)
        }
    }
    
    private func addOverlayViewWithMessage(message: LINMessage) {
        if message.state == LINMessageState.Submitted {
            var overlayImgName: String?
            if message.incoming {
                overlayImgName = "Box_chat_left_opacity"
            } else {
                overlayImgName = "Box_chat_right_opacity"
            }

            overlayView.frame = bubbleImageView.frame
            overlayView.image = UIImage(named: overlayImgName!)
            addSubview(overlayView)
        }
    }
    
    func openPhotoPreviewWithGesture(recognizer: UITapGestureRecognizer) {
        delegate?.bubbleCellDidOpenPhotoPreview(self)
    }
    
    // MARK: Actions
    
    func resendButtonTouched(sender: UIButton) {
        delegate?.bubbleCellDidStartResendMessage(self)
    }
    
    func toggleAudioButton(playButton: UIButton) {
        if playButton.selected {
            playButton.selected = false
            LINAudioHelper.sharedInstance.stopPlaying()
        }
        else {
            playButton.selected = true
            delegate?.bubbleCellDidStartPlayingRecord(self)
        }
    }
    
    // MARK: Utility methods
    
    class func maxWidthOfMessage() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width - 87
    }
    
    class func maxWidthOfPhotoMessage() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width - 100
    }
}

// MARK: LINAudioHelperPlayerDelegate

extension LINBubbleCell: LINAudioHelperPlayerDelegate {
    
    func audioHelperDidFinishPlaying(duration: NSTimeInterval) {
        let simplified = Int(duration + 0.5)
        durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
        playButton?.selected = false
        voiceProgressBar?.progress = 0
    }

    func audioHelperDidUpdateProgress(progress: NSTimeInterval, duration: NSTimeInterval) {
        if playButton?.selected == false {
            playButton?.selected = true
        }
        
        voiceProgressBar?.progress = Float(progress/duration)
        if Int(duration - progress - 0.1) < Int(duration - progress) {
            let simplified = Int(duration - progress)
            self.durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
        }
    }
}

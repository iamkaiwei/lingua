//
//  BubbleCell.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/18/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

let kTextMessageMaxWidth: CGFloat = 233
let kTextMessageMaxHeight: CGFloat = 9999
let kPhotoMessageMaxWidth: CGFloat = 200
let kPhotoMessageMaxHeight: CGFloat = 200
let kVoiceMessageMaxWidth: CGFloat = 233
let kVoiceMessageMaxHeight: CGFloat = 55
let kSideMargin: CGFloat = 10
let kBubbleCellHeightPadding: CGFloat = 5

protocol LINBubbleCellDelegate {
    func bubbleCell(bubbleCell: LINBubbleCell, updatePhotoWithMessage message: LINMessage)
    func bubbleCellDidStartPlayingRecord(bubbleCell: LINBubbleCell)
    func bubbleCellDidStopPlayingRecord(bubbleCell: LINBubbleCell)
}

class LINBubbleCell: UITableViewCell {
    var contentTextView: UITextView = UITextView()
    var bubbleImageView: UIImageView = UIImageView()
    var createAtLabel: UILabel = UILabel()
    var photoImgView: UIImageView = UIImageView()
    
    //Voice message
    var playButton: UIButton?
    var voiceProgressBar: UIProgressView?
    var durationLabel: UILabel?
    
    let textInsetsMine = UIEdgeInsetsMake(5, 10, 7, 17)
    let textInsetsSomeone = UIEdgeInsetsMake(5, 15, 7, 10)
    
    var delegate: LINBubbleCellDelegate?
   
    // Textkit
    private var emoticonsTextStorage = LINParsingEmoticonsTextStorage()

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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
        createAtLabel.font = UIFont.appRegularFontWithSize(10)
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
        
        let size = contentTextView.sizeThatFits(CGSize(width: kTextMessageMaxWidth, height: kTextMessageMaxHeight))
        let insets = (message.incoming == false ? textInsetsMine : textInsetsSomeone)
        let offsetX = (message.incoming == true ? 0 : frame.size.width  - size.width - insets.left - insets.right)
        
        contentTextView.frame = CGRectMake(offsetX + insets.left, insets.top, size.width, size.height)
        addSubview(contentTextView)
        
        // Bubble imageview
        bubbleImageView.frame = CGRect(x: contentTextView.frame.origin.x - 5, y: 0,
                                       width: contentTextView.frame.size.width + 10,
                                       height: contentTextView.frame.size.height)
        
        calcTimeFrameWithContentFrame(contentTextView.frame, message: message)
    }
    
    private func configureWithPhotoMessage(message: LINMessage) {
        if message.content == nil {
            println("Downloading photo message.")
            // Add photo to cell by image URL
            photoImgView.sd_setImageWithURL(NSURL(string: message.url!)) {
              (image, error, cacheType, imageURL) in
                if let tmpImage = image {
                    println("Finish downloading photo message.")
                    message.content = tmpImage
                    self.addPhotoToBubbleCellWithMessage(message)
                    
                    // Save photo to memory
                    self.delegate?.bubbleCell(self, updatePhotoWithMessage: message)
                    
                    // Save photo to camera roll
                    // UIImageWriteToSavedPhotosAlbum(tmpImage, nil, nil, nil)
                }
            }
        } else {
            // Add photo to cell by image
            self.addPhotoToBubbleCellWithMessage(message)
        }
    }
    
    private func configureWithVoiceMessage(message: LINMessage) {
        if message.content == nil && message.url != nil {
            LINNetworkClient.sharedInstance.downloadFile(message.url!, completion: { (data, error) in
                if data != nil {
                    println("Downloaded voice record successfully")
                    message.content = data
                }
            })
        }

        // Bubble imageview
        let x = message.incoming == true ? kSideMargin : CGRectGetWidth(frame) - kVoiceMessageMaxWidth - kSideMargin/2
        bubbleImageView.frame = CGRectMake(x, 5,  kVoiceMessageMaxWidth,  kVoiceMessageMaxHeight)
        calcTimeFrameWithContentFrame(bubbleImageView.frame, message: message)
        
        //Set up other UIs
        playButton = UIButton(frame: CGRectMake(x, 10, kVoiceMessageMaxHeight, kVoiceMessageMaxHeight))
        playButton?.setImage(UIImage(named: "PlayButton"), forState: .Normal)
        playButton?.setImage(UIImage(named: "PauseButton"), forState: .Selected)
        playButton?.addTarget(self, action: "toggleAudioButton:", forControlEvents: .TouchUpInside)
        addSubview(playButton!)
        
        voiceProgressBar = UIProgressView(frame: CGRectMake(CGRectGetMaxX(playButton!.frame) - 5, kVoiceMessageMaxHeight/2 + kSideMargin - 2, kVoiceMessageMaxWidth - CGRectGetWidth(playButton!.frame)*2, 2))
        voiceProgressBar?.progressTintColor = UIColor.appTealColor()
        voiceProgressBar?.progress = 1
        addSubview(voiceProgressBar!)
        
        durationLabel = UILabel()
        durationLabel?.font = UIFont.appLightFontWithSize(14)
        durationLabel?.textAlignment = .Center
        durationLabel?.text = "00:00"
        durationLabel?.numberOfLines = 0
        durationLabel?.sizeToFit()
        durationLabel?.frame.origin = CGPointMake(CGRectGetMaxX(voiceProgressBar!.frame) + kSideMargin, kVoiceMessageMaxHeight/2)
        addSubview(durationLabel!)
    }
    
    private func addPhotoToBubbleCellWithMessage(message: LINMessage) {
        var imageSize = (message.content as UIImage).size
        if imageSize.width > kPhotoMessageMaxWidth {
            imageSize.height /= imageSize.width / kPhotoMessageMaxWidth
            imageSize.width = CGFloat(kPhotoMessageMaxWidth)
        }
        
        photoImgView.image = message.content as UIImage
        photoImgView.layer.cornerRadius = 5.0
        photoImgView.layer.masksToBounds = true
        
        let insets = (message.incoming == false ? textInsetsMine : textInsetsSomeone)
        let offsetX = (message.incoming == true ? 0 : frame.size.width  - imageSize.width - insets.left - insets.right - 5)
        
        photoImgView.frame = CGRect(x: offsetX + insets.left + 2,
                                    y: insets.top + 15,
                                    width: imageSize.width,
                                    height: imageSize.height)
        addSubview(photoImgView)
        
        // Bubble imageview
        bubbleImageView.frame = CGRect(x: offsetX + insets.left - 5,
                                       y: 0,
                                       width: imageSize.width + 17,
                                       height: imageSize.height + 30)
        
        calcTimeFrameWithContentFrame(bubbleImageView.frame, message: message)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("openPhotoPreviewWithGesture:"))
        photoImgView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func calcTimeFrameWithContentFrame(contentFrame: CGRect, message: LINMessage) {
        // Bubble imageview
        let bubbleCapInsets = UIEdgeInsetsMake(20, 10, 10, 10)
        if message.incoming {
            bubbleImageView.image = UIImage(named: "ChatBoxLeft").resizableImageWithCapInsets(bubbleCapInsets)
        } else {
            bubbleImageView.image = UIImage(named: "ChatBoxRight").resizableImageWithCapInsets(bubbleCapInsets)
        }
        
        // Time label
        let contentFrame = contentFrame
        let offsetXCreateAtLabel = (message.incoming == true ? (contentFrame.origin.x + contentFrame.size.width + 20) :
            (contentFrame.origin.x - 60))
        createAtLabel.frame = CGRect(x: offsetXCreateAtLabel,
                                     y: contentFrame.origin.y + contentFrame.size.height / 2 - 10,
                                     width: 100,
                                     height: 20)
        createAtLabel.text = NSDateFormatter.hourDateFormatter().stringFromDate(message.sendDate).lowercaseString
    }
    
    func openPhotoPreviewWithGesture(recognizer: UITapGestureRecognizer) {
        let appDelegate = AppDelegate.sharedDelegate()
        let photoPreviewController = appDelegate.storyboard.instantiateViewControllerWithIdentifier("kLINPhotoPreviewController") as LINPhotoPreviewController
        photoPreviewController.photo = photoImgView.image
        
        let chatController = appDelegate.drawerController.presentedViewController as LINChatController
        chatController.presentViewController(photoPreviewController, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    func toggleAudioButton(playButton: UIButton) {
        playButton.selected = !playButton.selected
        playButton.selected ? delegate?.bubbleCellDidStartPlayingRecord(self) : delegate?.bubbleCellDidStopPlayingRecord(self)
    }
}

extension LINBubbleCell: LINAudioHelperPlayerDelegate {
    func audioHelperDidFinishPlaying() {
        playButton?.selected = false
    }
}

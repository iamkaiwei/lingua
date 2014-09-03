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
let kPhotoMessageMaxHeight: CGFloat = 230
let kVoiceMessageMaxWidth: CGFloat = 233
let kVoiceMessageMaxHeight: CGFloat = 55
let kSideMargin: CGFloat = 10
let kTextCellHeightPadding: CGFloat = 5
let kPhotoCellHeightPadding: CGFloat = 30

protocol LINBubbleCellDelegate {
    func bubbleCellDidStartPlayingRecord(bubbleCell: LINBubbleCell)
}

class LINBubbleCell: UITableViewCell, LINAudioHelperPlayerDelegate {
    var contentTextView: UITextView = UITextView()
    var bubbleImageView: UIImageView = UIImageView()
    var createAtLabel: UILabel = UILabel()
    var photoImgView: UIImageView = UIImageView()
    let placeholderImage = UIImage(named: "placeholder")
    
    //Voice message
    private var playButton: UIButton?
    private var voiceProgressBar: UIProgressView?
    private var durationLabel: UILabel?
    private var trackingTimer: NSTimer?
    private var progress: NSTimeInterval = 0

    private let textInsetsMine = UIEdgeInsetsMake(5, 10, 7, 17)
    private let textInsetsSomeone = UIEdgeInsetsMake(5, 15, 7, 10)
    
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
            // Resize place holder image
            let newSize = CGSize.getSizeFromImageURL(message.url! as String).scaledSize()
             message.content = placeholderImage.resizableImageWithNewSize(newSize)
             addPhotoToBubbleCellWithMessage(message)

            // Add photo to cell by image URL
            photoImgView.sd_setImageWithURL(NSURL(string: message.url!),
                                            placeholderImage: placeholderImage) {
              (image, error, cacheType, imageURL) in
                if error != nil {
                    println("Download image has some errors \(error!.description)")
                    return
                }

                if let tmpImage = image {
                    message.content = tmpImage
                    self.addPhotoToBubbleCellWithMessage(message)
                                      
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
                    message.duration = LINAudioHelper.sharedInstance.getDurationFromData(data!)
                    let simplified = Int(message.duration + 0.5)
                    self.durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
                }
            })
        }

        // Bubble imageview
        let x = message.incoming == true ? kSideMargin : CGRectGetWidth(frame) - kVoiceMessageMaxWidth - kSideMargin/2
        bubbleImageView.frame = CGRectMake(x, 0,  kVoiceMessageMaxWidth - 7,  kVoiceMessageMaxHeight - 5)
        calcTimeFrameWithContentFrame(bubbleImageView.frame, message: message)
        
        //Set up other UIs
        playButton = UIButton(frame: CGRectMake(x, 5, kVoiceMessageMaxHeight, kVoiceMessageMaxHeight))
        playButton?.setImage(UIImage(named: "PlayButton"), forState: .Normal)
        playButton?.setImage(UIImage(named: "PauseButton"), forState: .Selected)
        playButton?.addTarget(self, action: "toggleAudioButton:", forControlEvents: .TouchUpInside)
        addSubview(playButton!)
        
        voiceProgressBar = UIProgressView(frame: CGRectMake(CGRectGetMaxX(playButton!.frame) - 7, kVoiceMessageMaxHeight/2 + kSideMargin - 7, kVoiceMessageMaxWidth - CGRectGetWidth(playButton!.frame)*2, 2))
        voiceProgressBar?.progressTintColor = UIColor.appTealColor()
        voiceProgressBar?.trackTintColor = UIColor.lightGrayColor()
        addSubview(voiceProgressBar!)
        
        durationLabel = UILabel()
        durationLabel?.font = UIFont.appLightFontWithSize(14)
        durationLabel?.textAlignment = .Center
        let simplified = Int(message.duration + 0.5)
        durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
        durationLabel?.numberOfLines = 0
        durationLabel?.sizeToFit()
        durationLabel?.frame.origin = CGPointMake(CGRectGetMaxX(voiceProgressBar!.frame) + kSideMargin, kVoiceMessageMaxHeight/2 - 5)
        addSubview(durationLabel!)
    }
    
    private func addPhotoToBubbleCellWithMessage(message: LINMessage) {
        var imageSize = (message.content as UIImage).size.scaledSize()

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
        if playButton.selected {
            playButton.selected = false
            LINAudioHelper.sharedInstance.stopPlaying()
        }
        else {
            playButton.selected = true
            delegate?.bubbleCellDidStartPlayingRecord(self)
        }
    }

    func trackForDuration(duration: NSTimeInterval) {
        if voiceProgressBar == nil {
            return //Apparently this is not type .Voice
        }

        trackingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateProgressBar:", userInfo: duration, repeats: true)
    }

    func updateProgressBar(timer: NSTimer) {
        if let duration = timer.userInfo as? NSTimeInterval {
            progress += 0.1
            voiceProgressBar?.progress = Float(progress/duration)
            
            if Int(duration - progress - 0.1) < Int(duration - progress) {
                let simplified = Int(duration - progress)
                self.durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
                println(self.durationLabel!.text)
            }
        }
    }
    
    //MARK: LINAudioHelperPlayerDelegate
    
    func audioHelperDidFinishPlaying() {
        if let duration = trackingTimer!.userInfo as? NSTimeInterval {
            let simplified = Int(duration + 0.5)
            durationLabel?.text = String(format: "%02d:%02d", simplified/60, simplified%60)
        }

        playButton?.selected = false
        trackingTimer?.invalidate()
        voiceProgressBar?.progress = 0
        progress = 0
    }
}

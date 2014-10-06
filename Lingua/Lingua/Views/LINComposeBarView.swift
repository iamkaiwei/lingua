//
//  LINComposeBarView.swift
//  Lingua
//
//  Created by Hoang Ta on 8/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

let kTextViewMaxContentHeight: CGFloat = 100
let kTextViewPlaceHolderText = "Type a message..."
let kTextViewOuterMargin: CGFloat = 15

protocol LINComposeBarViewDelegate {
    func composeBar(composeBar: LINComposeBarView, sendMessage text: String)
    func composeBar(composeBar: LINComposeBarView, willShowKeyBoard rect: CGRect, duration: NSTimeInterval)
    func composeBar(composeBar: LINComposeBarView, willHideKeyBoard rect: CGRect, duration: NSTimeInterval)
    func composeBar(composeBar: LINComposeBarView, startPickingMediaWithPickerViewController picker: UIImagePickerController)
    func composeBar(composeBar: LINComposeBarView, didPickPhoto photo: UIImage, messageId: String)
    func composeBar(composeBar: LINComposeBarView, didUploadFile url: String, messageId: String)
    func composeBar(composeBar: LINComposeBarView, didFailToUploadFile error: NSError?, messageId: String)
    func composeBar(composeBar: LINComposeBarView, didRecord data: NSData, messageId: String)
    func composeBar(composeBar: LINComposeBarView, didFailToRecord error: NSError)
    func composeBar(composeBar: LINComposeBarView, willChangeHeight height: CGFloat)
}

class LINComposeBarView: UIView, LINEmoticonsViewDelegate, LINAudioHelperRecorderDelegate, UITextViewDelegate {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var voicePanelView: UIView!
    @IBOutlet weak var slideBack: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!

    var delegate: LINComposeBarViewDelegate?
    private var emoticonsView: LINEmoticonsView?
    private let defaultAnimationDuration = 0.3
    private var shouldCancelRecording = false
    private var initialFrameForSlideImage = CGRectZero
    private var recordingDuration: Int = 0
    private var recordingTimer: NSTimer?
    
    // Parsing emoticons
    private var emoticonsTextStorage = LINParsingEmoticonsTextStorage()
    private var currentContentHeight: CGFloat = 0

    func commonInit() {
        //Keyboards
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)

        //Emoticons View
        emoticonsView = UINib(nibName: "LINEmoticonsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? LINEmoticonsView
        emoticonsView?.delegate = self

        //Initialize UIs
        let contentView = UINib(nibName: "LINComposeBarView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
        contentView.frame = bounds
        addSubview(contentView)
        // Textview
        emoticonsTextStorage.addLayoutManager(textView.layoutManager)
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsetsMake(0, 0, 2, 0)
        emoticonsTextStorage.addPlaceHolderForTextViewWithText(kTextViewPlaceHolderText)
        let size = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, CGFloat(MAXFLOAT)))
        currentContentHeight = size.height
        speakButton.exclusiveTouch = true

        LINAudioHelper.sharedInstance.recorderDelegate = self
        self.textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentSize" {
            adjustTextViewFrameWithText("")
        }
    }

    override init() {
        super.init()
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func hide() {
        if !emoticonsView!.isHidden {
            hideEmoticonsView()
        }
        textView.resignFirstResponder()
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        // Remove white space from both ends of a string
        let text = emoticonsTextStorage.getOriginalText()
        if text.utf16Count > 0 {
            // Send message
            delegate?.composeBar(self, sendMessage: text)

             clearTextView()
            
            // Toggle send/speak buttons
            if !textView.isFirstResponder() {
                sendButton.hidden = true
                speakButton.hidden = false
            }
        }
    }
    
    private func clearTextView() {
        emoticonsTextStorage.clearPlaceHolderForTextView()
        textView.selectedRange = NSMakeRange(0, 0)
        textViewDidChange(textView)
    }
    
    @IBAction func expandOptions(sender: UIButton) {
        textView.becomeFirstResponder()
        if emoticonsView!.isHidden {
            showEmoticonsView()
        } else {
            hideEmoticonsView()
        }
    }

    @IBAction func startSpeaking(sender: UIButton) {
        clearTextView()
        hide()
        initialFrameForSlideImage = slideBack.frame
        moreButton.setImage(UIImage(named: "Recording"), forState: UIControlState.Normal)
        voicePanelView.hidden = false
        recordingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
        LINAudioHelper.sharedInstance.startRecording()
    }

    @IBAction func stopSpeaking(sender: UIButton) {
        if shouldCancelRecording {
            shouldCancelRecording = false
            LINAudioHelper.sharedInstance.cancelRecording()
        }
        else {
            LINAudioHelper.sharedInstance.finishRecording()
        }
    }
    
    func timerTick(timer: NSTimer) {
        recordingDuration++
        durationLabel.text = String(format: "%02d:%02d", recordingDuration/60, recordingDuration%60)

        //Add blinking effect
        if shouldCancelRecording {
            return
        }
        
        UIView.animateWithDuration(0, animations: { self.moreButton.alpha = 0 }, completion: { _ in
            UIView.animateWithDuration(0, delay: 0.5, options: .BeginFromCurrentState, animations: { self.moreButton.alpha = 1 }, completion: nil)
        })
    }

    @IBAction func startPanning(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .Began, .Changed:
            let currentTouchLocation = sender.locationInView(voicePanelView)
            if currentTouchLocation.x > CGRectGetMidX(initialFrameForSlideImage) {
                slideBack.frame = initialFrameForSlideImage
                return
            }

            if currentTouchLocation.x < 5 {
                slideBack.center.x = 5
                return
            }

            if currentTouchLocation.x < 100 && !shouldCancelRecording {
                shouldCancelRecording = true
                durationLabel.alpha = 0.5
                moreButton.setImage(UIImage(named: "Trash"), forState: UIControlState.Normal)
            }

            if currentTouchLocation.x >= 100 && shouldCancelRecording {
                shouldCancelRecording = false
                durationLabel.alpha = 1
                moreButton.setImage(UIImage(named: "Recording"), forState: UIControlState.Normal)
            }

            slideBack.center.x = currentTouchLocation.x

            case .Ended:
                stopSpeaking(sender.view as UIButton)

            default: return
        }
    }

    private func showEmoticonsView() {
        moreButton.setImage(UIImage(named: "icn_cancel_blue"), forState: UIControlState.Normal)
        if let solidView = superview {
            emoticonsView!.isHidden = false
            textView.inputView = emoticonsView!
            textView.reloadInputViews()
        }
    }
    
    private func hideEmoticonsView() {
        moreButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)
        emoticonsView!.isHidden = true
        textView.inputView = nil
        textView.reloadInputViews()
    }

    // MARK: Keyboards
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        sendButton.hidden = false
        speakButton.hidden = true
        let keyboardInfo = getKeyboardInfoWithNotification(notification)
        delegate?.composeBar(self, willShowKeyBoard: keyboardInfo.rect, duration: keyboardInfo.duration)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        if emoticonsTextStorage.getOriginalText().utf16Count < 1 || emoticonsTextStorage.enablePlaceHolderText {
            sendButton.hidden = true
            speakButton.hidden = false
        }
        let keyboardInfo = getKeyboardInfoWithNotification(notification)
        delegate?.composeBar(self, willHideKeyBoard: keyboardInfo.rect, duration: keyboardInfo.duration)
    }
    
    private func getKeyboardInfoWithNotification(notification: NSNotification) -> (rect: CGRect, duration: Double) {
        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        return (keyboardRect, duration)
    }

    // MAKR: EmoticonsViewDelegate
    
    func emoticonsView(emoticonsView: LINEmoticonsView, startPickingMediaWithPickerViewController picker: UIImagePickerController) {
        delegate?.composeBar(self, startPickingMediaWithPickerViewController: picker)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didPickPhoto photo: UIImage, messageId: String) {
        hideEmoticonsView()
        delegate?.composeBar(self, didPickPhoto: photo, messageId: messageId)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didUploadPhoto imageURL: String, messageId: String) {
        delegate?.composeBar(self, didUploadFile: imageURL, messageId: messageId)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didFailToUploadPhoto error: NSError?, messageId: String) {
        delegate?.composeBar(self, didFailToUploadFile: error, messageId: messageId)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didCancelWithPickerController picker: UIImagePickerController) {
        hideEmoticonsView()
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didSelectEmoticonAtIndex index: Int) {
        let selectedRange = textView.selectedRange
        if index == kEmoticonsViewCancelButtonIndex {
            if selectedRange.location >= 1 {
                let removedRange = NSMakeRange(selectedRange.location - 1, 1)
                textView.selectedRange = NSMakeRange(removedRange.location, 0)
                emoticonsTextStorage.replaceCharactersInRange(removedRange, withString: "")
            }
        } else {
            var row = index
            if index < kEmoticonsViewCancelButtonIndex {
                row += 1
            }
            let tmpKey = LINParsingEmoticonsTextStorage.serchEmoticonKeyByName("emoticon_\(row)")
            
            emoticonsTextStorage.insertAttributedString(NSAttributedString(string: tmpKey), atIndex: selectedRange.location)
            textView.selectedRange = NSMakeRange(selectedRange.location + 1, 0)
        }
        textViewDidChange(textView)
    }

    // MAKR: LINAudioHelperRecorderDelegate

    func audioHelperDidComposeVoice(voice: NSData) {
        println(voice.length)
        resetStateForNextRecord()
        
        // Generate a message id
        let messageId = NSUUID.UUID().UUIDString

        delegate?.composeBar(self, didRecord: voice, messageId: messageId)
        
        // Upload record to server
        LINNetworkClient.sharedInstance.uploadFile(voice, fileType: LINFileType.Audio, completion: { (fileURL, error) -> Void in
            if let tmpFileURL = fileURL {
                self.delegate?.composeBar(self, didUploadFile: tmpFileURL, messageId: messageId)
                return
            }
            
            self.delegate?.composeBar(self, didFailToUploadFile: error, messageId: messageId)
        })
    }

    func audioHelperDidFailToComposeVoice(error: NSError) {
        delegate?.composeBar(self, didFailToRecord: error)
        resetStateForNextRecord()
    }

    func audioHelperDidCancelRecording() {
        resetStateForNextRecord()
    }

    func resetStateForNextRecord() {
        recordingTimer?.invalidate()
        recordingDuration = 0
        durationLabel.text = "00:00"
        durationLabel.alpha = 1
        slideBack.center.x = CGRectGetMidX(self.initialFrameForSlideImage)
        voicePanelView.hidden = true
        moreButton.hidden = false
        moreButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)
        emoticonsTextStorage.addPlaceHolderForTextViewWithText(kTextViewPlaceHolderText)
    }

    // MAKR: UITextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
        if !emoticonsView!.isHidden {
            hideEmoticonsView()
        }
        return true
    }

    func textViewDidChange(tv: UITextView!) {
        sendButton.enabled = emoticonsTextStorage.getOriginalText().utf16Count > 0
        sendButton.setTitleColor(sendButton.enabled ? UIColor.mainAppColor() : UIColor.lightGrayColor(), forState: UIControlState.Normal)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if emoticonsTextStorage.getOriginalText() == kTextViewPlaceHolderText {
            clearTextView()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if emoticonsTextStorage.getOriginalText() == "" {
            emoticonsTextStorage.addPlaceHolderForTextViewWithText(kTextViewPlaceHolderText)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.utf16Count > 1 {
            // if the replacement text count > 1 char that mean user paste a bulk of text
            // Call the text view to re-adjust it manually
            adjustTextViewFrameWithText(text)
        }
        return true
    }
    
    func adjustTextViewFrameWithText(newInputText: String) {
        let fullText = emoticonsTextStorage.getOriginalText().stringByAppendingString(newInputText)
        let newSize = fullText.sizeOfStringUseTextStorage()
        
        scrollContentOfTextViewToCaret()
        
        let newHeight = min(newSize.height,kTextViewMaxContentHeight) + kTextViewOuterMargin
        delegate?.composeBar(self, willChangeHeight: newHeight)
    }
    
    // MAKR: Utility methods
    
    private func scrollContentOfTextViewToCaret() {
        textView.layoutManager.ensureLayoutForTextContainer(textView.textContainer)
        let caretRect = textView.caretRectForPosition(textView.endOfDocument)
        
        textView.scrollRectToVisible(caretRect, animated: false)
    }
}

//
//  LINComposeBarView.swift
//  Lingua
//
//  Created by Hoang Ta on 8/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit


protocol LINComposeBarViewDelegate {
    func composeBar(composeBar: LINComposeBarView, sendMessage text: String)
    func composeBar(composeBar: LINComposeBarView, willShowKeyBoard rect: CGRect, duration: NSTimeInterval)
    func composeBar(composeBar: LINComposeBarView, willHideKeyBoard rect: CGRect, duration: NSTimeInterval)
    func composeBar(composeBar: LINComposeBarView, startPickingMediaWithPickerViewController picker: UIImagePickerController)
    func composeBar(composeBar: LINComposeBarView, didPickPhoto photo: UIImage)
    func composeBar(composeBar: LINComposeBarView, didUploadPhoto imageURL: String)
    func composeBar(composeBar: LINComposeBarView, didRecord data: NSData)
    func composeBar(composeBar: LINComposeBarView, didUploadRecord url: String)
}

class LINComposeBarView: UIView {

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
        textView.layer.cornerRadius = 10
        speakButton.exclusiveTouch = true

        // emoticonsTextStorage.addLayoutManager(textView.layoutManager)
        LINAudioHelper.sharedInstance.recorderDelegate = self
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
        if textView.text.utf16Count > 0 {
            delegate?.composeBar(self, sendMessage: textView.text)
            textView.text = ""
            textViewDidChange(textView)
        }
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
        hide()
        initialFrameForSlideImage = slideBack.frame
        moreButton.setImage(UIImage(named: "Recording"), forState: UIControlState.Normal)
        voicePanelView.hidden = false
        recordingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
        LINAudioHelper.sharedInstance.startRecording()
    }

    @IBAction func stopSpeaking(sender: UIButton) {
        recordingTimer?.invalidate()
        recordingDuration = 0
        durationLabel.text = String(format: "%02d:%02d", recordingDuration/60, recordingDuration%60)
        LINAudioHelper.sharedInstance.stopRecording()
        slideBack.center.x = CGRectGetMidX(self.initialFrameForSlideImage)
        voicePanelView.hidden = true
        moreButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)
    }

    func timerTick(timer: NSTimer) {
        recordingDuration++
        durationLabel.text = String(format: "%02d:%02d", recordingDuration/60, recordingDuration%60)
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
        let keyboardInfo = getKeyboardInfoWithNotification(notification)
        delegate?.composeBar(self, willShowKeyBoard: keyboardInfo.rect, duration: keyboardInfo.duration)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        let keyboardInfo = getKeyboardInfoWithNotification(notification)
        delegate?.composeBar(self, willHideKeyBoard: keyboardInfo.rect, duration: keyboardInfo.duration)
    }
    
    private func getKeyboardInfoWithNotification(notification: NSNotification) -> (rect: CGRect, duration: Double) {
        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        return (keyboardRect, duration)
    }
}
 
extension LINComposeBarView: LINEmoticonsViewDelegate {
    // MAKR: EmoticonsViewDelegate
    
    func emoticonsView(emoticonsView: LINEmoticonsView, startPickingMediaWithPickerViewController picker: UIImagePickerController) {
        delegate?.composeBar(self, startPickingMediaWithPickerViewController: picker)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didPickPhoto photo: UIImage) {
        hideEmoticonsView()
        delegate?.composeBar(self, didPickPhoto: photo)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didUploadPhoto imageURL: String) {
        delegate?.composeBar(self, didUploadPhoto: imageURL)
    }

    func emoticonsView(emoticonsView: LINEmoticonsView, didCancelWithPickerController picker: UIImagePickerController) {
        hideEmoticonsView()
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, didSelectEmoticonAtIndex index: Int) {
        let tmpKey = LINParsingEmoticonsTextStorage.serchEmoticonKeyByName("emoticon_\(index + 1)")
        textView.text = textView.text.stringByAppendingString(tmpKey)
        textViewDidChange(textView)
    }
}

extension LINComposeBarView: LINAudioHelperRecorderDelegate {
    
    func audioHelperDidComposeVoice(voice: NSData) {
        println(voice.length)
        if shouldCancelRecording {
            shouldCancelRecording = false
        }
        else {
            delegate?.composeBar(self, didRecord: voice)
            // Upload record to server
            LINNetworkClient.sharedInstance.uploadFile(voice, fileType: LINFileType.Audio, completion: { (fileURL, error) -> Void in
                if let tmpFileURL = fileURL {
                    self.delegate?.composeBar(self, didUploadRecord: tmpFileURL)
                }
           })
        }
    }
}

extension LINComposeBarView: UITextViewDelegate {

    func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
        if !emoticonsView!.isHidden {
            hideEmoticonsView()
        }
        return true
    }

    func textViewDidChange(tv: UITextView!) {
        if tv.text.utf16Count > 0 {
            sendButton.hidden = false
            speakButton.hidden = true
        }
        else {
            sendButton.hidden = true
            speakButton.hidden = false
        }
    }
}

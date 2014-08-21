//
//  LINComposeBarView.swift
//  Lingua
//
//  Created by Hoang Ta on 8/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINComposeBarViewDelegate {
    func composeBar(composeBar: LINComposeBarView, sendMessage message: String)
    func composeBar(composeBar: LINComposeBarView, willShowKeyBoard rect: CGRect, duration: NSTimeInterval)
    func composeBar(composeBar: LINComposeBarView, willHideKeyBoard rect: CGRect, duration: NSTimeInterval)
    func composeBar(composeBar: LINComposeBarView, startPickingMediaWithPickerViewController picker: UIImagePickerController)
    func composeBar(composeBar: LINComposeBarView, replyWithPhoto photo: UIImage)
    func composeBar(composeBar: LINComposeBarView, replyWithImageURL imageURL: String)
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
    private var shouldFinishRecording = false
    private var initialFrameForSlideImage = CGRectZero
    private var recordingDuration: Int = 0
    private var recordingTimer: NSTimer?
    
    func commonInit() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        emoticonsView = UINib(nibName: "LINEmoticonsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? LINEmoticonsView
        emoticonsView?.delegate = self
        let contentView = UINib(nibName: "LINComposeBarView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
        contentView.frame = bounds
        addSubview(contentView)
        textView.layer.cornerRadius = 10
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
        moreButton.setImage(UIImage(named: "Recording"), forState: UIControlState.Normal)
        voicePanelView.hidden = false
        recordingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
        LINAudioHelper.sharedInstance.startRecording()
    }

    func timerTick(timer: NSTimer) {
        recordingDuration++
        durationLabel.text = String(format: "%02d:%02d", recordingDuration/60, recordingDuration%60)
    }

    @IBAction func startPanning(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .Began:
            moreButton.setImage(UIImage(named: "Trash"), forState: UIControlState.Normal)
            initialFrameForSlideImage = slideBack.frame
            case .Changed:
            let translation = sender.translationInView(voicePanelView)
            if translation.x + sender.view.center.x > CGRectGetMidX(initialFrameForSlideImage) {
                return
            }
            if translation.x + sender.view.center.x < 20 {
                moreButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)
                voicePanelView.hidden = true
                shouldFinishRecording = true
                return
            }
            sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y)
            sender.setTranslation(CGPointZero, inView: voicePanelView)

            case .Ended:
                if shouldFinishRecording {
                    recordingTimer?.invalidate()
                    recordingDuration = 0
                    durationLabel.text = String(format: "%02d:%02d", recordingDuration/60, recordingDuration%60)
                    LINAudioHelper.sharedInstance.stopRecording()
                }
                else {
                    moreButton.setImage(UIImage(named: "Recording"), forState: UIControlState.Normal)
                }
                shouldFinishRecording = false
                UIView.animateWithDuration(0.2, animations: {
                    sender.view.center.x = CGRectGetMidX(self.initialFrameForSlideImage)
                })

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
    
    func emoticonsView(emoticonsView: LINEmoticonsView, replyWithPhoto photo: UIImage) {
        hideEmoticonsView()
        delegate?.composeBar(self, replyWithPhoto: photo)
    }
    
    func emoticonsView(emoticonsView: LINEmoticonsView, replyWithImageURL imageURL: String) {
        delegate?.composeBar(self, replyWithImageURL: imageURL)
    }

    func emoticonsView(emoticonsView: LINEmoticonsView, didCancelWithPickerController picker: UIImagePickerController) {
        hideEmoticonsView()
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

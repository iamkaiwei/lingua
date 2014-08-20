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
}

class LINComposeBarView: UIView {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!

    private var emoticonsView: LINEmoticonsView?
    var delegate: LINComposeBarViewDelegate?
    let defaultAnimationDuration = 0.3
    var shouldChangeFrameForKeyboard = true

    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        emoticonsView = UINib(nibName: "LINEmoticonsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? LINEmoticonsView
        let contentView = UINib(nibName: "LINComposeBarView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
        contentView.frame = bounds
        addSubview(contentView)
        textView.layer.cornerRadius = 10

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func hide() {
        moreButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)
        if !emoticonsView!.isHidden {
            hideEmoticonsView()
            shouldChangeFrameForKeyboard = false
            textView.becomeFirstResponder()
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
        if emoticonsView!.isHidden {
            showEmoticonsView()
        } else {
            shouldChangeFrameForKeyboard = false
            textView.becomeFirstResponder()
            hideEmoticonsView()
        }
    }

    private func showEmoticonsView() {
        moreButton.setImage(UIImage(named: "icn_cancel_blue"), forState: UIControlState.Normal)
        if let solidView = superview {
            if textView.isFirstResponder() {
                shouldChangeFrameForKeyboard = false
                textView.resignFirstResponder()
            }
            else {
                let rect = CGRectMake(0, CGRectGetHeight(solidView.frame) - CGRectGetHeight(emoticonsView!.frame), CGRectGetWidth(emoticonsView!.frame), CGRectGetHeight(emoticonsView!.frame))
                delegate?.composeBar(self, willShowKeyBoard: rect, duration: defaultAnimationDuration)
            }
            emoticonsView!.showInView(solidView)
        }
    }
    
    private func hideEmoticonsView() {
        moreButton.setImage(UIImage(named: "Icn_add"), forState: UIControlState.Normal)
        emoticonsView?.hide()
    }

    // MARK: Keyboards
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        if !shouldChangeFrameForKeyboard {
            shouldChangeFrameForKeyboard = true
            return
        }
        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        delegate?.composeBar(self, willShowKeyBoard: keyboardRect, duration: duration)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        if !shouldChangeFrameForKeyboard {
            shouldChangeFrameForKeyboard = true
            return
        }
        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        delegate?.composeBar(self, willHideKeyBoard: keyboardRect, duration: duration)
    }
}
 
extension LINComposeBarView: UITextViewDelegate {

    func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
        if !emoticonsView!.isHidden {
            hideEmoticonsView()
            shouldChangeFrameForKeyboard = false
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

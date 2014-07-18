//
//  LINChatController.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/14/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation
import QuartzCore

class LINChatController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var inputContainerView: UIView
    @IBOutlet var inputTextView: UITextView
    @IBOutlet var speakButton: UIButton
    @IBOutlet var sendButton: UIButton
    @IBOutlet var titleNavLabel: UILabel
    @IBOutlet var tableView: UITableView
    
    @IBOutlet var inputContainerViewBottomLayoutGuideConstraint: NSLayoutConstraint
    
    var bubblesDataArray = [BubbleData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInputContainerView()
        configureTapGestureOnTableView()
        
        loadBubblesData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:",
            name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:",
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: Configuration
    
    func configureInputContainerView () {
        inputContainerView.layer.borderColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0).CGColor
        inputContainerView.layer.borderWidth = 0.5
    }
    
    func configureTapGestureOnTableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
        tableView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Actions
    
    @IBAction func buttonSendTouched(sender: UIButton) {
        if (inputTextView.text.utf16count > 0) {
            let bubbleData = BubbleData(text: inputTextView.text, createAt: NSDate(), bubbleType: BubbleType.Mine)
           
            addBubbleViewCellWithBubbleData(bubbleData)
        }
    }
    
    @IBAction func backButtonTouched(sender: UIButton) {
        if navigationController {
            navigationController.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
       }
    }
    
    func didTapOnTableView(sender: UITapGestureRecognizer) {
        inputTextView.resignFirstResponder()
    }
    
    // MARK: UITableView datasource
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return bubblesDataArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cellIdentifier = "kBubbleCell"
        var cell: BubbleCell? = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? BubbleCell
        if !cell {
            cell = BubbleCell()
        }
        
        let bubbleData = bubblesDataArray[indexPath.row]
        cell!.configureCellWithBubbleData(bubbleData)
        
        return cell
    }

    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let bubbleData = bubblesDataArray[indexPath.row]
        return bubbleData.insets.top + bubbleData.view.frame.size.height + bubbleData.insets.bottom + 10;
    }
    
    // MARK: Functions 
    
    func addBubbleViewCellWithBubbleData(bubbleData: BubbleData) {
        bubblesDataArray.append(bubbleData)
        
        let indexPaths = [NSIndexPath(forRow: bubblesDataArray.count - 1, inSection: 0)]
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    func loadBubblesData() {
        tableView.reloadData()
        scrollBubbleTableViewToBottomAnimated(false)
    }
    
    func scrollBubbleTableViewToBottomAnimated(animated: Bool) {
        let lastRowIdx = bubblesDataArray.count - 1
        
        if lastRowIdx >= 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIdx, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }

    // MARK: Keyboard Events Notifications

    func handleKeyboardWillShowNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showKeyboard: true)
        
        scrollBubbleTableViewToBottomAnimated(true)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showKeyboard: false)
    }
    
    func keyboardWillChangeFrameWithNotification(notfication: NSNotification, showKeyboard: Bool) {
        let userInfo = notfication.userInfo
        let kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue().size
        var animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue

        if showKeyboard {
            // Convert the keyboard frame from screen to view coordinates.
            let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
            let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
            let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
            
            // The input container view should be adjusted, update the constant for this constraint.
            self.inputContainerViewBottomLayoutGuideConstraint.constant -= originDelta
        } else {
            self.inputContainerViewBottomLayoutGuideConstraint.constant = 0
        }
        
        view.setNeedsUpdateConstraints()
    
        UIView.animateWithDuration(animationDuration, animations: {
            var inputContainerFrame = self.inputContainerView.frame
            var tableFrame = self.tableView.frame
            
            if showKeyboard {
                inputContainerFrame.origin.y -= kbSize.height
                tableFrame.size.height -= kbSize.height
            } else {
                inputContainerFrame.origin.y += kbSize.height
                tableFrame.size.height += kbSize.height
            }
            
            self.inputContainerView.frame = inputContainerFrame
            self.tableView.frame = tableFrame
            
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK - TextView Delegate
    
    func textViewDidChange(textView: UITextView!) {
        if  textView.text.utf16count > 0 {
            sendButton.hidden = false
            speakButton.hidden = true
        } else {
            sendButton.hidden = true
            speakButton.hidden = false
        }
   }
}

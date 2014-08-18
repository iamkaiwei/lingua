//
//  LINEmoticonsView.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/10/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

protocol LINEmoticonsViewDelegate {
    func emoticonsView(emoticonsView: LINEmoticonsView, startPickingMediaWithPickerViewController picker: UIImagePickerController)
    func emoticonsView(emoticonsView: LINEmoticonsView, replyWithPhoto photo: UIImage)
    func emoticonsView(emoticonsView: LINEmoticonsView, replyWithImageURL imageURL: String)
}

class LINEmoticonsView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isHidden: Bool = true
    var delegate: LINEmoticonsViewDelegate? {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.registerClass(LINEmoticonCell.self, forCellWithReuseIdentifier: "EmoticonCellIdentifier")
        }
    }
}

extension LINEmoticonsView {
    // MARK: Actions
    
    @IBAction func imagesButtonTouched(sender: UIButton) {
        showPickerControllerWithSourceType(.PhotoLibrary)
    }
    
    @IBAction func photosButtonTouched(sender: UIButton) {
        showPickerControllerWithSourceType(.Camera)
    }
}

extension LINEmoticonsView {
    // MARK: Functions
    
    private func showPickerControllerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) &&  sourceType == .Camera {
            UIAlertView(title: "Error", message: "Device has no camera.", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = sourceType
        
        delegate?.emoticonsView(self, startPickingMediaWithPickerViewController: picker)
    }
    
    func showInViewController(viewController: UIViewController) {
        viewController.view.addSubview(self)
        
        var frame = self.frame
        frame.origin.y = viewController.view.frame.size.height
        self.frame = frame
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            var frame = self.frame
            frame.origin.y = viewController.view.frame.size.height - self.frame.size.height
            self.frame = frame
            }, completion: { finished in
        })
        
        isHidden = false
    }
    
    func hide() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            var frame = self.frame
            frame.origin.y += self.frame.size.height
            self.frame = frame
            }, completion: { finished in
                self.removeFromSuperview()
        })
        
        isHidden = true
    }
}

extension LINEmoticonsView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        let chooseImage = info[UIImagePickerControllerEditedImage] as UIImage
        delegate?.emoticonsView(self, replyWithPhoto: chooseImage)
        
        // Upload photo to server
        LINNetworkClient.sharedInstance.uploadImage(chooseImage, completion: { (imageURL, error) -> Void in
            if let imgURL = imageURL {
                self.delegate?.emoticonsView(self, replyWithImageURL: imgURL)
            }
        })
        
        hidePhotosScreenWithPickerViewController(picker)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        hidePhotosScreenWithPickerViewController(picker)
    }
    
    private func hidePhotosScreenWithPickerViewController(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}

extension LINEmoticonsView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoticonCellIdentifier", forIndexPath: indexPath) as LINEmoticonCell
        cell.imageView.image = UIImage(named: "emoticon_\(indexPath.row + 1)")
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        println("Emotion \(indexPath.row) is selected.")
    }
}

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
    func emoticonsView(emoticonsView: LINEmoticonsView, didPickPhoto photo: UIImage)
    func emoticonsView(emoticonsView: LINEmoticonsView, didUploadPhoto imageURL: String)
    func emoticonsView(emoticonsView: LINEmoticonsView, didCancelWithPickerController picker: UIImagePickerController)
    func emoticonsView(emoticonsView: LINEmoticonsView, didSelectEmoticonAtIndex index: Int)
}

class LINEmoticonsView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isHidden: Bool = true
    var delegate: LINEmoticonsViewDelegate? {
        didSet {
            collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 5)
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
}

extension LINEmoticonsView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        let chooseImage = info[UIImagePickerControllerEditedImage] as UIImage
        delegate?.emoticonsView(self, didPickPhoto: chooseImage)
        
        // Upload photo to server
        let imageData = UIImageJPEGRepresentation(chooseImage, 0.8) as NSData
        LINNetworkClient.sharedInstance.uploadFile(imageData, fileType: LINFileType.Image, completion: { (fileURL, error) -> Void in
            if let tmpFileURL = fileURL {
                self.delegate?.emoticonsView(self, didUploadPhoto: tmpFileURL)
            }
        })
        
        hidePhotosScreenWithPickerViewController(picker)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        delegate?.emoticonsView(self, didCancelWithPickerController: picker)
        hidePhotosScreenWithPickerViewController(picker)
    }
    
    private func hidePhotosScreenWithPickerViewController(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}

extension LINEmoticonsView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoticonCellIdentifier", forIndexPath: indexPath) as LINEmoticonCell
        cell.configureAtIndexPath(indexPath)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.emoticonsView(self, didSelectEmoticonAtIndex: indexPath.row)
    }
}

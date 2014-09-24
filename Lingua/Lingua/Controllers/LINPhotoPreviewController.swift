//
//  LINPhotoPreviewController.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/14/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPhotoPreviewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        photoImgView.image = photo
        scrollView.contentSize = photo!.size
        
        // Touch gestures
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }

    @IBAction func closeButtonTouched(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIScrollView Delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImgView
    }
    
    // MARK: Gesture Actions
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(scrollView)
        println("Point in view = \(pointInView)")
        let newZoomScale = (scrollView.zoomScale ==  scrollView.maximumZoomScale ? scrollView.minimumZoomScale : scrollView.maximumZoomScale)
        let zoomRect = zoomRectForScale(newZoomScale, center: pointInView)
        
        scrollView.zoomToRect(zoomRect, animated: true)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // Using aspect fit, scale the image (size) to the image view's size.
        if scrollView.zoomScale ==  scrollView.maximumZoomScale {
            let sizeBeingScaledTo = getAspectFitSizeFromAspectRatio(photo!.size, boundingSize: photoImgView.frame.size)
            let deltaX = (photoImgView.frame.size.width - sizeBeingScaledTo.width) / 2
            let deltaY = (photoImgView.frame.size.height - sizeBeingScaledTo.height) / 2
            
            scrollView.contentInset = UIEdgeInsetsMake(-deltaY, -deltaX, -deltaY, -deltaX)
        } else {
            scrollView.contentInset = UIEdgeInsetsZero
        }
    }
    
    // MARK: Utility methods
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        // As the zoom scale decreases, so more content is visible,
        let w = scrollView.frame.size.width / scale
        let h = scrollView.frame.size.height / scale
        
        // Choose an origin so as to get the right center.
        let x = center.x - (w / 2.0)
        let y = center.y - (h / 2.0)
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func getAspectFitSizeFromAspectRatio(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
        var aspectFitSize = boundingSize
    
        let width = boundingSize.width / aspectRatio.width
        let height = boundingSize.height / aspectRatio.height
        
        if height < width {
            aspectFitSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
        } else {
            aspectFitSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
        }
        return aspectFitSize
    }
}

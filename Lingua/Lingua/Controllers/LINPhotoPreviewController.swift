//
//  LINPhotoPreviewController.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/14/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPhotoPreviewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationView: UIView!
    var photoImgView: UIImageView!
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        photoImgView = UIImageView(image: photo)
        photoImgView.frame = CGRect(origin: CGPointMake(0, 0), size: photo!.size)
        photoImgView.contentMode = UIViewContentMode.ScaleAspectFit
        
        scrollView.addSubview(photoImgView)
        scrollView.contentSize = photo!.size
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        let viewSize = getViewSize()
        let scaleWidth = viewSize.width / scrollView.contentSize.width
        let scaleHeight = viewSize.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 1.5
        scrollView.zoomScale = minScale;
        
        centerScrollViewContents()
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
        let pointInView = recognizer.locationInView(photoImgView)
        let newZoomScale = (scrollView.zoomScale ==  scrollView.maximumZoomScale ? scrollView.minimumZoomScale : scrollView.maximumZoomScale)
        let zoomRect = zoomRectForScale(newZoomScale, center: pointInView)
        
        scrollView.zoomToRect(zoomRect, animated: true)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    // MARK: Utility methods
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        // As the zoom scale decreases, so more content is visible,
        let w = scrollView.bounds.size.width / scale
        let h = scrollView.bounds.size.height / scale
        
        // Choose an origin so as to get the right center.
        let x = center.x - (w / 2.0)
        let y = center.y - (h / 2.0)
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func centerScrollViewContents() {
        let boundsSize = getViewSize()
        var contentsFrame = photoImgView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        photoImgView.frame = contentsFrame
    }
    
    private func getViewSize() -> CGSize {
        return CGSizeMake(self.view.frame.width, self.view.frame.height - navigationView.frame.size.height)
    }
}

//
//  LINLoginView.swift
//  Lingua
//
//  Created by Hoang Ta on 6/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINLoginView: UIView {


    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(UINib(nibName: "LINLoginView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView)
    }
    
    
}

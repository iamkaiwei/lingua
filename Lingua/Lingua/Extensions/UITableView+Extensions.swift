//
//  UITableView+NetworkHelper.swift
//  Lingua
//
//  Created by TaiVuong on 8/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

extension UITableView{
    func registerForNetworkStatusNotification(#lossConnection:String , restoreConnection:String) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidLostConnection", name: lossConnection, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidRestoreConnection", name: restoreConnection, object: nil)
    }
    
    func appDidLostConnection(notification:NSNotification) {
        var currentTopInset = self.contentInset.top
        self.contentInset = UIEdgeInsets(top: currentTopInset + 30, left: 0, bottom: 0, right: 0)
    }
    
    func appDidRestoreConnection(notification:NSNotification) {
        var currentTopInset = self.contentInset.top
        self.contentInset = UIEdgeInsets(top: currentTopInset - 30, left: 0, bottom: 0, right: 0 )
        
    }
}
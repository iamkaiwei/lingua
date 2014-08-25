//
//  LINArrayDataSource.swift
//  Lingua
//
//  Created by Kiet Nguyen on 7/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

typealias TableViewCellConfigureClosure = (cell: UITableViewCell, item: AnyObject, indexPath: NSIndexPath) -> Void

class LINArrayDataSource: NSObject, UITableViewDataSource {
    var items: Array<AnyObject>
    let cellIdentifier: String
    let configureClosure: TableViewCellConfigureClosure
    
    init(items: Array<AnyObject>, cellIdentifier: String, configureClosure: TableViewCellConfigureClosure) {
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.configureClosure = configureClosure
        
        super.init()
    }
    
    // MARK: Utils
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return items[indexPath.row]
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        
        let item: AnyObject = itemAtIndexPath(indexPath)
        configureClosure(cell: cell, item: item, indexPath: indexPath)

        return cell
    }
}
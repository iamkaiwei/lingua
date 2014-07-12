//
//  LINCountrySelectorController.swift
//  Lingua
//
//  Created by Hoang Ta on 7/11/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINCountrySelectorController: LINViewController {

    @IBOutlet var tableView: UITableView

    let countryNames = LINResourceHelper.countryNames()
    var countryNameHeaders = LINResourceHelper.countryNameHeaders()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.registerClass(LINTableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.sectionIndexColor = UIColor.appTealColor()
    }
    

}

extension LINCountrySelectorController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let char = countryNameHeaders[section]
        return countryNames.filter{ $0.hasPrefix(char) }.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
        let char = countryNameHeaders[indexPath.section]
        cell.textLabel.text = countryNames.filter{ $0.hasPrefix(char) }[indexPath.row]
        return cell
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView!) -> [AnyObject]! {
        return countryNameHeaders
    }
    
    func tableView(tableView: UITableView!, sectionForSectionIndexTitle title: String!, atIndex index: Int) -> Int {
        return index;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return countryNameHeaders.count
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
}
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

    let (names, codes) = LINResourceHelper.countryNamesAndCodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.registerClass(LINTableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    }
    
}

extension LINCountrySelectorController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
        cell.textLabel.text = names[indexPath.row]
        return cell
    }
    
    
}
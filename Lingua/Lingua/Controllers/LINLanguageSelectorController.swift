//
//  LINCountrySelectorController.swift
//  Lingua
//
//  Created by Hoang Ta on 7/11/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINLanguageSelectorControllerDelegate {
    func controller(controller: LINLanguageSelectorController, didSelectCountry country: String)
}

class LINLanguageSelectorController: LINViewController {

    @IBOutlet weak var tableView: UITableView!

    private var countryNames = [String]()
    private var countryNameHeaders = [String]()
    var delegate: LINLanguageSelectorControllerDelegate?
    private var loadingView = LINLoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.showInView(self.view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LINResourceHelper.countryNamesAndHeaders {
            self.loadingView.hide()
            self.countryNames = $0
            self.countryNameHeaders = $1
            self.tableView.reloadData()
        }
    }

    func prepareTableView() {
        tableView.registerClass(LINCountryCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.sectionIndexColor = UIColor.appTealColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
}

extension LINLanguageSelectorController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        delegate?.controller(self, didSelectCountry: cell.textLabel.text)
        navigationController.popViewControllerAnimated(true)
    }
}
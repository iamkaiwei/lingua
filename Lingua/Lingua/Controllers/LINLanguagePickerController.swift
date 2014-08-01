//
//  LINCountrySelectorController.swift
//  Lingua
//
//  Created by Hoang Ta on 7/11/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINLanguagePickerControllerDelegate {
    func controller(controller: LINLanguagePickerController, didSelectCountry country: String)
}

class LINLanguagePickerController: LINViewController {

    @IBOutlet weak var tableView: UITableView!

    private var languages = [[String]]()
    private var headers = [String]()
    var delegate: LINLanguagePickerControllerDelegate?
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
        LINResourceHelper.languages {
            self.languages = $0
            self.headers = $1
            self.loadingView.hide()
            self.tableView.reloadData()
        }
    }

    func prepareTableView() {
        tableView.registerClass(LINCountryCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.sectionIndexColor = UIColor.appTealColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
}

extension LINLanguagePickerController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return languages[section].count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
        cell.textLabel.text = languages[indexPath.section][indexPath.row]
        return cell
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView!) -> [AnyObject]! {
        return headers
    }
    
    func tableView(tableView: UITableView!, sectionForSectionIndexTitle title: String!, atIndex index: Int) -> Int {
        return index;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return headers.count
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        delegate?.controller(self, didSelectCountry: cell.textLabel.text)
        navigationController.popViewControllerAnimated(true)
    }
}
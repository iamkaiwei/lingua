//
//  LINPickLearningViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickLearningViewController: UIViewController {

    let subjects = [0: "Language", 1: "Written Proficiency", 2: "Spoken Proficiency"]
    let languages = ["English", "Chinese"]
    let proficiencies = ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]
    var availableSection: Int?
    var massArray = [[], [], []]
    
    @IBOutlet var tableView: UITableView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.bounces = false
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CellIdentifier")
    }
    
}

extension LINPickLearningViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return massArray[section].count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "CellIdentifier")
        }
        
        cell.textLabel.text = "\(massArray[indexPath.section][indexPath.row])"
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return LINLanguagePickingHeaderView.totalSection()
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = LINLanguagePickingHeaderView(frame: CGRectZero)
        header.title.text = subjects[section]
        header.index = section
        header.delegate = self
        return header
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return LINLanguagePickingHeaderView.heightForHeader()
    }
}

extension LINPickLearningViewController: LINLanguagePickingHeaderViewDelegate {
    
    func didTapShow(header: LINLanguagePickingHeaderView) {
        
        if header.index == availableSection {
            massArray = [[], [], []]
            availableSection = nil
        } else {
            switch header.index {
            case 0: massArray = [languages, [], []]
            case 1: massArray = [[], proficiencies, []]
            case 2: massArray = [[], [], proficiencies]
            default: massArray = [[], [], []]
            }
            availableSection = header.index
        }
        tableView.reloadData()
    }
}

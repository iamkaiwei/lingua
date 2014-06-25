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
    @IBOutlet var titleLabel: UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = UIFont.appRegularFontWithSize(20)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CellIdentifier")
    }
    
}

extension LINPickLearningViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return massArray[section].count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.textLabel.font = UIFont.appRegularFontWithSize(14)
        cell.textColor = UIColor.grayColor()
        cell.accessoryView = UIImageView(image: UIImage(named: "Checked")) //This is not working at the moment, possibly due to the xcode 6 beta 2
        cell.textLabel.text = "\(massArray[indexPath.section][indexPath.row])"
        if indexPath.section == 0 {
            cell.image = nil //First section lists languages only, no proficiency image required
        } else {
            cell.image = UIImage(named: "Proficiency\(indexPath.row)")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return LINLanguagePickingHeaderView.totalSection()
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = LINLanguagePickingHeaderView(frame: CGRectZero)
        header.titleLabel.text = subjects[section]
        header.index = section
        header.delegate = self
        return header
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if massArray[section].count > 0 {
            return LINLanguagePickingHeaderView.heightForOpenHeader()
        }
        
        return LINLanguagePickingHeaderView.heightForClosedHeader()
    }
    
    func tableView(tableView: UITableView!, viewForFooterInSection section: Int) -> UIView! {
        let footer = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 1))
        footer.backgroundColor = UIColor.appLightGrayColor()
        return footer
    }
    
    func tableView(tableView: UITableView!, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}

extension LINPickLearningViewController: LINLanguagePickingHeaderViewDelegate {
    
    func didTapHeader(header: LINLanguagePickingHeaderView) {
        
        let indexSet = NSMutableIndexSet()
        if availableSection != nil {
            indexSet.addIndex(availableSection!)
        }
        
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
            indexSet.addIndex(availableSection!)
        }
        tableView.reloadSections(NSIndexSet(indexSet: indexSet), withRowAnimation: .Automatic)
    }
}

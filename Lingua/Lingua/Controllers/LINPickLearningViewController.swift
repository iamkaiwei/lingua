//
//  LINPickLearningViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickLearningViewController: UIViewController {

    let subjects = ["Language", "Written Proficiency", "Spoken Proficiency"]
    var selectedSectionIndex: Int? = 0
    let dataArray = [["English", "Chinese"],
                    ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"],
                    ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]]
    
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
        if selectedSectionIndex == section {
            return dataArray[section].count
        }
        return 0
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.textLabel.font = UIFont.appRegularFontWithSize(14)
        cell.textColor = UIColor.grayColor()
        cell.accessoryView = UIImageView(image: UIImage(named: "Checked")) //This is not working at the moment, possibly due to the xcode 6 beta 2
        cell.textLabel.text = "\(dataArray[indexPath.section][indexPath.row])"
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
        if section == 0 {
            header.isExpanded = true
        }
        return header
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedSectionIndex == section {
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
        var oldIndexPaths = Array<NSIndexPath>()
        if selectedSectionIndex != nil {
            for index in 0..dataArray[selectedSectionIndex!].count {
                oldIndexPaths.append(NSIndexPath(forRow: index, inSection: selectedSectionIndex!))
            }
        }
        
        var newIndexPaths = Array<NSIndexPath>()
        if selectedSectionIndex == header.index {
            selectedSectionIndex = nil
        }
        else {
            selectedSectionIndex = header.index
            for index in 0..dataArray[selectedSectionIndex!].count {
                newIndexPaths.append(NSIndexPath(forRow: index, inSection: selectedSectionIndex!))
            }
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(oldIndexPaths, withRowAnimation: .None)
        tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .None)
        tableView.endUpdates()
    }
}

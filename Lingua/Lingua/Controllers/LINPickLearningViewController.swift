//
//  LINPickLearningViewController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickLearningViewController: UIViewController {

    let subjects = ["Language", "Written", "Spoken"]
    let dataArray = [["English", "Chinese"],
                    ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"],
                    ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]]
    var selectedSectionIndex: Int? = 0
    var selectedIndexPaths = Dictionary<Int, NSIndexPath>()
    
    @IBOutlet var tableView: UITableView
    @IBOutlet var titleLabel: UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = UIFont.appRegularFontWithSize(20)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
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
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
        cell.textLabel.text = "\(dataArray[indexPath.section][indexPath.row])"
        cell.image = indexPath.section == 0 ? nil : UIImage(named: "Proficiency\(indexPath.row)")

        if indexPath == selectedIndexPaths[indexPath.section] {
            cell.accessoryView = UIImageView(image: UIImage(named: "Checked"))
        }
        cell.accessoryView = UIImageView(image: UIImage(named: "Checked")) //TODO: This line should be removed after the SDK work properly (for now it doesn't do anything..)
        return cell
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.font = UIFont.appThinFontWithSize(14)
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
        if let oldIndexPath = selectedIndexPaths[indexPath.section] {
            if indexPath != oldIndexPath {
                selectedIndexPaths[indexPath.section] = indexPath
                tableView.reloadRowsAtIndexPaths([oldIndexPath, indexPath], withRowAnimation: .None)
            }
        } else {
            selectedIndexPaths[indexPath.section] = indexPath
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }

        let header = tableView.headerViewForSection(indexPath.section) as LINLanguagePickingHeaderView
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.section == 0 {
            let label = UILabel()
            label.font = UIFont.appLightFontWithSize(14)
            label.text = cell.textLabel.text
            label.sizeToFit()
            header.accessoryView = label
        } else {
            let imageView = UIImageView(image: cell.image)
            header.accessoryView = imageView
        }
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

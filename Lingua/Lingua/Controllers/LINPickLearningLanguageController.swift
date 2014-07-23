//
//  LINPickLearningLanguageController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickLearningLanguageController: LINViewController {

    let subjects = ["Language", "Written", "Spoken"]
    let dataArray = ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]
    var selectedSectionIndex: Int? = 1
    var selectedIndexPaths = Dictionary<Int, NSIndexPath>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(LINTableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    }
}

extension LINPickLearningLanguageController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if selectedSectionIndex == section && section != 0 {
            return dataArray.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell
        cell.textLabel.text = "\(dataArray[indexPath.row])"
        cell.imageView.image = indexPath.section == 0 ? nil : UIImage(named: "Proficiency\(indexPath.row)")

        if indexPath == selectedIndexPaths[indexPath.section] {
            cell.accessoryView = UIImageView(image: UIImage(named: "Checked"))
        }
        cell.accessoryView = UIImageView(image: UIImage(named: "Checked")) //TODO: This line should be removed after the SDK work properly (for now it doesn't do anything..)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return LINLanguagePickingHeaderView.totalSection()
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = LINLanguagePickingHeaderView(frame: CGRectZero)
        header.accessoryViewType = section == 0 ? .Label : .Image
        header.titleLabel.text = subjects[section]
        header.index = section
        header.delegate = self
        if section == 0 {
            header.accessoryDirection = .Right
        }
        if section == selectedSectionIndex {
            header.accessoryDirection = .Up
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        header.updateAccessoryViewWith(cell.imageView.image)
    }
}

extension LINPickLearningLanguageController: LINLanguagePickingHeaderViewDelegate {
    
    func didTapHeader(header: LINLanguagePickingHeaderView) {
        if header.index == 0 {
            let viewController = storyboard.instantiateViewControllerWithIdentifier("kLINCountrySelectorController") as LINCountrySelectorController
            viewController.delegate = self
            navigationController!.pushViewController(viewController, animated: true)
            return;
        }
        
        var oldIndexPaths = Array<NSIndexPath>()
        if selectedSectionIndex != nil {
            for index in 0..<dataArray.count {
                oldIndexPaths.append(NSIndexPath(forRow: index, inSection: selectedSectionIndex!))
            }
        }
        
        var newIndexPaths = Array<NSIndexPath>()
        if selectedSectionIndex == header.index {
            selectedSectionIndex = nil
        }
        else {
            if selectedSectionIndex != nil {
                let headerView = tableView.headerViewForSection(selectedSectionIndex!) as LINLanguagePickingHeaderView
                headerView.accessoryDirection = .Down
            }
            selectedSectionIndex = header.index
            for index in 0..<dataArray.count {
                newIndexPaths.append(NSIndexPath(forRow: index, inSection: selectedSectionIndex!))
            }
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(oldIndexPaths, withRowAnimation: .None)
        tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .None)
        tableView.endUpdates()
    }
}

extension LINPickLearningLanguageController: LINCountrySelectorControllerDelegate {
    func controller(controller: LINCountrySelectorController, didSelectCountry country: String) {
        //Update accessory view for header at section 0 i.e Language
        let header = tableView.headerViewForSection(0) as LINLanguagePickingHeaderView
        header.updateAccessoryViewWith(country)
    }
}

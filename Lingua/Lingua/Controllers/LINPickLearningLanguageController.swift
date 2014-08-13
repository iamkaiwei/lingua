//
//  LINPickLearningLanguageController.swift
//  Lingua
//
//  Created by Hoang Ta on 6/22/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINPickLearningLanguageController: LINViewController {

    private let subjects = ["Language", "Writing", "Speaking"]
    private let proficiencies = ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]
    private let accessoryImages = [UIImage(named: "Proficiency0"), UIImage(named: "Proficiency1"), UIImage(named: "Proficiency2"), UIImage(named: "Proficiency3"), UIImage(named: "Proficiency4")]
    private var selectedSectionIndex: Int?
    private var selectedIndexPaths = [Int: NSIndexPath]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
    }
    
    func prepareTableView() {
        selectedSectionIndex = 1
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(LINProficiencyCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.registerClass(LINLanguagePickingHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderIdentifier")
    }
    
    @IBAction func next(sender: UIButton) {
        if LINUserManager.sharedInstance.currentUser?.learningLanguage == nil {
            UIAlertView(title: nil, message: "Please choose a learning language.", delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        
        if let indexPath = selectedIndexPaths[1] {
            LINUserManager.sharedInstance.currentUser?.speakingProficiency = LINProficiency.fromProficiency(indexPath.row)
        }
        else {
            UIAlertView(title: nil, message: "Please choose a speaking proficiency.", delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        
        if let indexPath = selectedIndexPaths[2] {
            LINUserManager.sharedInstance.currentUser?.writingProficiency = LINProficiency.fromProficiency(indexPath.row)
        }
        else {
            UIAlertView(title: nil, message: "Please choose a writing proficiency.", delegate: nil, cancelButtonTitle: "Okay").show()
            return
        }
        
        performSegueWithIdentifier("kPickNativeViewControllerSegue", sender: self)
    }
}

extension LINPickLearningLanguageController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return (selectedSectionIndex == section) ? proficiencies.count : 0
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as LINProficiencyCell
        cell.textLabel.text = proficiencies[indexPath.row]
        cell.imageView.image = accessoryImages[indexPath.row]
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return LINLanguagePickingHeaderView.totalSection()
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderIdentifier") as LINLanguagePickingHeaderView
        header.accessoryViewType = (section == 0) ? .Label : .Image
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
        let cell = tableView.cellForRowAtIndexPath(indexPath) as LINProficiencyCell
        cell.setChecked(true, animated: true)
        
        if let oldIndexPath = selectedIndexPaths[indexPath.section] {
            if indexPath == oldIndexPath {
                return
            }
            else {
                let previouslySelectedCell = tableView.cellForRowAtIndexPath(oldIndexPath) as LINProficiencyCell
                previouslySelectedCell.setChecked(false, animated: false)
                selectedIndexPaths[indexPath.section] = indexPath
            }
        }
        else {
            selectedIndexPaths[indexPath.section] = indexPath
        }

        //Update header UI
        let header = tableView.headerViewForSection(indexPath.section) as LINLanguagePickingHeaderView
        header.updateAccessoryViewWith(cell.imageView.image)
    }
}

extension LINPickLearningLanguageController: LINLanguagePickingHeaderViewDelegate {
    
    func didTapHeader(header: LINLanguagePickingHeaderView) {
        if header.index == 0 {
            let viewController = storyboard.instantiateViewControllerWithIdentifier("kLINLanguagePickerController") as LINLanguagePickerController
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
            return;
        }
        
        var oldIndexPaths = [NSIndexPath]()
        var newIndexPaths = [NSIndexPath]()
        
        if selectedSectionIndex == nil {
            for index in 0..<proficiencies.count {
                newIndexPaths.append(NSIndexPath(forRow: index, inSection: header.index))
            }
            selectedSectionIndex = header.index
            header.accessoryDirection = .Up
        }
        else if selectedSectionIndex == header.index {
            for index in 0..<proficiencies.count {
                oldIndexPaths.append(NSIndexPath(forRow: index, inSection: header.index))
            }
            selectedSectionIndex = nil
            header.accessoryDirection = .Down
        }
        else {
            for index in 0..<proficiencies.count {
                oldIndexPaths.append(NSIndexPath(forRow: index, inSection: selectedSectionIndex!))
            }
            for index in 0..<proficiencies.count {
                newIndexPaths.append(NSIndexPath(forRow: index, inSection: header.index))
            }
            let previouslySelectedHeader = tableView.headerViewForSection(selectedSectionIndex!) as LINLanguagePickingHeaderView
            previouslySelectedHeader.accessoryDirection = .Down
            selectedSectionIndex = header.index
            header.accessoryDirection = .Up
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(oldIndexPaths, withRowAnimation: .None)
        tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .None)
        tableView.endUpdates()
        
        if selectedSectionIndex == nil {
            return
        }
        else if let indexPath = selectedIndexPaths[selectedSectionIndex!] {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as LINProficiencyCell
            cell.setChecked(true, animated: false)
        }
    }
}

extension LINPickLearningLanguageController: LINLanguagePickerControllerDelegate {
    func controller(controller: LINLanguagePickerController, didSelectLanguage language: LINLanguage) {
        //Update accessory view for header at section 0 i.e Language
        let header = tableView.headerViewForSection(0) as LINLanguagePickingHeaderView
        LINUserManager.sharedInstance.currentUser?.learningLanguage = language
        header.updateAccessoryViewWith(language.languageName)
        navigationController.popToViewController(self, animated: true)
    }
}

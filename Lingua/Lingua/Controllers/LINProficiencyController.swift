//
//  LINProficiencyController.swift
//  Lingua
//
//  Created by Hoang Ta on 9/23/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

protocol LINProficiencyControllerDelegate {
    func controller(controller: LINProficiencyController, didSelectProficiency proficiency: LINProficiency)
}

class LINProficiencyController: LINViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate: LINProficiencyControllerDelegate?
    var titleText: String?
    
    private let proficiencies = ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]
    private let accessoryImages = [UIImage(named: "Proficiency0"), UIImage(named: "Proficiency1"), UIImage(named: "Proficiency2"), UIImage(named: "Proficiency3"), UIImage(named: "Proficiency4")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.text = titleText
        titleLabel?.setValue(UIFont.appLightFontWithSize(18), forKey: "font")
        tableView.registerClass(LINProficiencyCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.tableFooterView = UIView()
    }
}

extension LINProficiencyController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proficiencies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as LINProficiencyCell
        cell.textLabel?.text = proficiencies[indexPath.row]
        cell.imageView?.image = accessoryImages[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.controller(self, didSelectProficiency: LINProficiency.fromProficiency(indexPath.row)!)
    }
}

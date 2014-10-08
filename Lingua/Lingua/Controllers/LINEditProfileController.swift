//
//  LINEditProfileController.swift
//  Lingua
//
//  Created by Hoang Ta on 9/19/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINEditProfileController: LINViewController, LINAboutMeControllerDelegate, LINLanguagePickerControllerDelegate, LINProficiencyControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var nativeLanguage: UILabel!
    @IBOutlet weak var learningLanguage: UILabel!
    @IBOutlet weak var writingProficiency: UIImageView!
    @IBOutlet weak var speakingProficiency: UIImageView!
    @IBOutlet weak var logoutView: UIView!
    
    private var me: LINUser?
    private var newAboutMe: String?
    private var newNativeLanguage: LINLanguage?
    private var newLearningLanguage: LINLanguage?
    private var newWritingProficiency: LINProficiency?
    private var newSpeakingProficiency: LINProficiency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        me = LINUserManager.sharedInstance.currentUser
        firstName.text = me?.firstName
        lastName.text = me?.lastName
        gender.text = me?.gender.capitalizedString
        nativeLanguage.text = me?.nativeLanguage?.languageName
        learningLanguage.text = me?.learningLanguage?.languageName
        writingProficiency.image = UIImage(named: "Proficiency\((me?.writingProficiency?.proficiencyID ?? 1) - 1)")
        speakingProficiency.image = UIImage(named: "Proficiency\((me?.speakingProficiency?.proficiencyID ?? 1) - 1)")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(logoutView.frame), CGRectGetMaxY(logoutView.frame))
    }
    
    @IBAction func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func aboutYou(sender: UITapGestureRecognizer) {
        let aboutMeVC = storyboard!.instantiateViewControllerWithIdentifier("kLINAboutMeController") as LINAboutMeController
        aboutMeVC.delegate = self
        aboutMeVC.aboutMe = me?.introduction ?? ""
        navigationController?.pushViewController(aboutMeVC, animated: true)
    }
    
    @IBAction func genderToggle(sender: UITapGestureRecognizer) {
        gender.text = (gender.text == "Male") ? "Female" : "Male"
        
    }
    
    @IBAction func nativeLanguagePick(sender: UITapGestureRecognizer) {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("kLINLanguagePickerController") as LINLanguagePickerController
        viewController.delegate = self
        viewController.titleText = "Native Language"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func learningLanguagePick(sender: UITapGestureRecognizer) {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("kLINLanguagePickerController") as LINLanguagePickerController
        viewController.delegate = self
        viewController.titleText = "Learning Language"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func writingProficiencyPick(sender: UITapGestureRecognizer) {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("kLINProficiencyController") as LINProficiencyController
        viewController.delegate = self
        viewController.titleText = "Writing Proficiency"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func speakingProficiencyPick(sender: UITapGestureRecognizer) {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("kLINProficiencyController") as LINProficiencyController
        viewController.delegate = self
        viewController.titleText = "Speaking Proficiency"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func logOut(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
        AppDelegate.sharedDelegate().showOnboardingScreen()
        LINFacebookManager.sharedInstance.logout()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //MARK: LINAboutMeControllerDelegate
    func controller(controller: LINAboutMeController, didUpdateInfo info: String) {
        newAboutMe = info
    }
    
    //MARK: LINLanguagePickerControllerDelegate
    func controller(controller: LINLanguagePickerController, didSelectLanguage language: LINLanguage) {
        if controller.titleLabel?.text == "Native Language" {
            newNativeLanguage = language
            nativeLanguage.text = language.languageName
        }
        else {
            newLearningLanguage = language
            learningLanguage.text = language.languageName
        }
        navigationController?.popToViewController(self, animated: true)
    }
    
    //MARK: LINProficiencyControllerDelegate
    func controller(controller: LINProficiencyController, didSelectProficiency proficiency: LINProficiency) {
        if controller.titleLabel?.text == "Writing Proficiency" {
            newWritingProficiency = proficiency
            writingProficiency.image = UIImage(named: "Proficiency\(proficiency.proficiencyID - 1)")
        }
        else {
            newSpeakingProficiency = proficiency
            speakingProficiency.image = UIImage(named: "Proficiency\(proficiency.proficiencyID - 1)")
        }
        navigationController?.popToViewController(self, animated: true)
    }
}

//
//  AddChildTableViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

class AddChildTableViewController: UITableViewController {
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var genderSwith: UISwitch!
    var birthDate: NSDate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getProfile {(profile, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                    self.lastNameText.text = profile?.lastName
                })
        }
        
    }
    
    func showError(message : String) {
        let alert = UIAlertController(title: "Invalid Input", message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func birthDayEditing(sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        birthDate = sender.date
    }
    
    @IBAction func registerTouched(sender: UIButton) {
        if firstNameText.text! == "" {
            showError("invalid first name")
            return
        }
        if lastNameText.text! == "" {
            showError("invalid last name")
            return
        }
        
        if birthDate == nil {
            showError("enter a birth day, it is important")
            return
        }
        
        delay(seconds: 2.0, completion: {
                SwiftSpinner.hide()
            })
        var gender: OTSGender = OTSGender.Female
        if genderSwith.on {
            gender = OTSGender.Male
        }
        // ask language to user
        let language : String = NSBundle.mainBundle().preferredLocalizations.first!
        
        let child: OTSChild = OTSChild()
        child.fistName = firstNameText.text!
        child.lastName = lastNameText.text!
        child.gender = gender
        child.language = language
        child.birthDay = Int64(birthDate!.timeIntervalSince1970)
        
        SwiftSpinner.show("adding...", animated: true)
        
        otsimo.addChild(firstNameText.text!, lastName: lastNameText.text!,
            gender: gender, birthDay: birthDate!, language: language) {err in
            
            delay(seconds: 1.5, completion: {
                    SwiftSpinner.hide()
                })
            
            dispatch_async(dispatch_get_main_queue(), {
                    switch (err) {
                    case .None:
                        SwiftSpinner.show("added", animated: false)
                        self.infoLabel.text = "added \(err)"
                        print(err)
                    default:
                        SwiftSpinner.show("failed to\nadd", animated: false)
                        self.infoLabel.text = "failed \(err)"
                        print(err)
                    }
                })
        }
    }
}


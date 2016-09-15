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
    @IBOutlet weak var genderSwith: UISwitch!

    @IBOutlet weak var infoLabel: UILabel!
    var birthDate: Date? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getProfile { (profile, error) -> Void in
            self.lastNameText.text = profile?.lastName
        }
    }

    func showError(_ message : String) {
        let alert = UIAlertController(title: "Invalid Input", message: message,
            preferredStyle: UIAlertControllerStyle.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func birthDayEditing(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddChildTableViewController.datePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
    }

    func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateTextField.text = dateFormatter.string(from: sender.date)
        birthDate = sender.date
    }

    @IBAction func registerTouched(_ sender: UIButton) {
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
        var gender: OTSGender = OTSGender.female
        if genderSwith.isOn {
            gender = OTSGender.male
        }
        // ask language to user
        let language : String = Bundle.main.preferredLocalizations.first!

        let child: OTSChild = OTSChild()
        child.firstName = firstNameText.text!
        child.lastName = lastNameText.text!
        child.gender = gender
        child.language = language
        child.locale = Locale.current.identifier
        child.birthDay = Int64(birthDate!.timeIntervalSince1970)
        
        let _=SwiftSpinner.show("adding...", animated: true)

        otsimo.addChild(child: child) { err in
                delay(seconds: 1.5) { SwiftSpinner.hide() }
                switch (err) {
                case .none:
                    let _=SwiftSpinner.show("added", animated: false)
                    self.infoLabel.text = "added \(err)"
                    print(err)
                default:
                    let _=SwiftSpinner.show("failed to\nadd", animated: false)
                    self.infoLabel.text = "failed \(err)"
                    print(err)
                }
        }
    }
}

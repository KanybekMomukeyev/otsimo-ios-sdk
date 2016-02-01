//
//  UpdateProfileViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 07/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

class UpdateProfileViewController: UITableViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var languageText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var streetText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var postalCodeText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    
    @IBOutlet weak var asd: UILabel!
    var initialProfile: OTSProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("getting\ndata...", animated: true)
        otsimo.getProfile() {profile, error in
            switch (error) {
            case OtsimoError.None:
                print("successfully get profile \(profile!)")
                if let pro = profile {
                    SwiftSpinner.hide()
                    self.initialProfile = pro
                    self.emailText.text = pro.email
                    self.firstNameText.text = pro.firstName
                    self.lastNameText.text = pro.lastName
                    self.phoneText.text = pro.mobilePhone
                    self.languageText.text = pro.language
                    if let a = pro.address {
                        self.cityText.text = a.city
                        self.streetText.text = a.streetAddress
                        self.stateText.text = a.state
                        self.postalCodeText.text = a.zipCode
                        self.countryText.text = a.countryCode
                    }
                } else {
                    SwiftSpinner.show("error", animated: false)
                    delay(seconds: 0.7) {
                        SwiftSpinner.hide()
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                }
            default:
                print("ERROR \(error)")
                SwiftSpinner.show("error", animated: false)
                delay(seconds: 0.7) {
                    SwiftSpinner.hide()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        }
    }
    
    func showError(message : String) {
        let alert = UIAlertController(title: "Invalid Input", message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeEmailTouched(sender: UIButton) {
        if emailText.text != initialProfile?.email {
            if let t = emailText.text {if t.characters.count == 0 {
                    showError("enter a valid email")
                    return
                }
            }
        } else {
            showError("enter a valid email")
            return
        }
        SwiftSpinner.show("updating...", animated: true)
        otsimo.changeEmail(emailText.text!) {err in
            switch (err) {
            case .None:
                self.initialProfile?.email = self.emailText.text
                SwiftSpinner.show("success", animated: false)
                delay(seconds: 0.8) {SwiftSpinner.hide()}
            default:
                SwiftSpinner.show("failed", animated: false)
                delay(seconds: 0.8) {SwiftSpinner.hide()}
            }
        }
    }
    
    func checkChanges(tField: UITextField, initial: String?, min: Int) -> Bool {
        if tField.text != initial {
            if let t = tField.text {
                if t.characters.count > min {
                    return true
                }
            }
        }
        return false
    }
    
    @IBAction func updateTouched(sender: UIButton) {
        if initialProfile == nil {
            return
        }
        let p = OTSProfile()
        var changesAreMade = false
        
        if checkChanges(firstNameText, initial: initialProfile!.firstName, min: 0) {
            changesAreMade = true
            p.firstName = firstNameText.text!
        }
        if checkChanges(lastNameText, initial: initialProfile!.lastName, min: 0) {
            changesAreMade = true
            p.lastName = lastNameText.text!
        }
        if checkChanges(phoneText, initial: initialProfile!.mobilePhone, min: 7) {
            changesAreMade = true
            p.mobilePhone = phoneText.text!
        }
        if checkChanges(languageText, initial: initialProfile!.language, min: 2) {
            changesAreMade = true
            p.language = languageText.text!
        }
        
        if changesAreMade {
            SwiftSpinner.show("updating...", animated: true)
            otsimo.updateProfile(p) {err in
                switch (err) {
                case .None:
                    self.syncProfiles(p)
                    SwiftSpinner.show("success", animated: false)
                    delay(seconds: 0.8) {SwiftSpinner.hide()}
                default:
                    SwiftSpinner.show("failed", animated: false)
                    delay(seconds: 0.8) {SwiftSpinner.hide()}
                }
            }
        } else {
            showError("nothings changed")
        }
    }
    
    func syncProfiles(newPro: OTSProfile) {
        if let fn = newPro.firstName {
            initialProfile?.firstName = fn
        }
        if let ln = newPro.lastName {
            initialProfile?.lastName = ln
        }
        if let fn = newPro.language {
            initialProfile?.language = fn
        }
        if let ln = newPro.mobilePhone {
            initialProfile?.mobilePhone = ln
        }
    }
}

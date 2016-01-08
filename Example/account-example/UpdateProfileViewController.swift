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
    
    var emailInitial: String = ""
    var fistNameInitial: String = ""
    var lastNameInitial: String = ""
    var profileFetched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("getting\ndata...", animated: true)
        otsimo.getProfile() {profile, error in
            dispatch_async(dispatch_get_main_queue(), {
                    switch (error) {
                    case OtsimoError.None:
                        print("successfully get profile \(profile!)")
                        if let pro = profile {
                            SwiftSpinner.hide()
                            self.profileFetched = true
                            self.emailInitial = pro.email
                            self.fistNameInitial = pro.firstName
                            self.lastNameInitial = pro.lastName
                            self.emailText!.text = pro.email
                            self.firstNameText!.text = pro.firstName
                            self.lastNameText!.text = pro.lastName
                        } else {
                            SwiftSpinner.show("error", animated: false)
                            delay(seconds: 0.7, completion: {
                                    SwiftSpinner.hide()
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                })
                        }
                    default:
                        print("ERROR \(error)")
                        SwiftSpinner.show("error", animated: false)
                        delay(seconds: 0.7, completion: {
                                SwiftSpinner.hide()
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            })}
                })
        }
    }
    func showError(message : String) {
        let alert = UIAlertController(title: "Invalid Input", message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func updateTouched(sender: UIButton) {
        if !profileFetched {
            return
        }
        let p = OTSProfile()
        var emailUpdating = false
        var firstNameUpdating = false
        var lastNameUpdating = false
        if emailText.text != emailInitial {
            if let t = emailText.text {
                if t.characters.count > 0 {
                    emailUpdating = true
                    p.email = t
                }
            }
        }
        
        if firstNameText.text != fistNameInitial {
            if let t = firstNameText.text {
                if t.characters.count > 0 {
                    firstNameUpdating = true
                    p.firstName = t
                }
            }
        }
        
        if lastNameText.text != lastNameInitial {
            if let t = lastNameText.text {
                if t.characters.count > 0 {
                    lastNameUpdating = true
                    p.lastName = t
                }
            }
        }
        
        if emailUpdating || firstNameUpdating || lastNameUpdating {
            SwiftSpinner.show("updating...", animated: true)
            otsimo.updateProfile(p) {err in
                switch (err) {
                case .None:
                    SwiftSpinner.show("success", animated: false)
                    delay(seconds: 0.8, completion: {
                            SwiftSpinner.hide()
                        })
                    dispatch_async(dispatch_get_main_queue(), {
                            if emailUpdating {
                                self.emailInitial = p.email!
                            }
                            if firstNameUpdating {
                                self.fistNameInitial = p.firstName!
                            }
                            if lastNameUpdating {
                                self.lastNameInitial = p.lastName!
                            }
                        })
                default:
                    SwiftSpinner.show("failed", animated: false)
                    delay(seconds: 0.8, completion: {
                            SwiftSpinner.hide()
                        })
                }
            }
        } else {
            showError("nothings changed")
        }
    }
}

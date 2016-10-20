//
//  ChangePasswordViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 07/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit

enum ChangePasswordValidation {
    case success
    case mismatch
    case short
    case invalidOld
    case samePassword
}

class ChangePasswordViewController: UITableViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var newPasswordRetypeText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var oldPasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func validateNewPassword() -> ChangePasswordValidation {
        if newPasswordText.text! != newPasswordRetypeText.text! {
            return .mismatch
        }
        if let count = newPasswordText.text?.characters.count {
            if count < 6 {
                return .short
            }
        } else {
            return .short
        }
        if let count = oldPasswordText.text?.characters.count {
            if count == 0 {
                return .invalidOld
            }
        } else {
            return .invalidOld
        }
        
        if newPasswordText.text == oldPasswordText.text! {
            return .samePassword
        }
        return .success
    }
    
    @IBAction func changePasswordTouched(_ sender: UIButton) {
        SwiftSpinner.show("changing...", animated: true)
        let res = validateNewPassword()
        switch (res) {
        case .success:
            otsimo.changePassword(old: oldPasswordText.text!, newPassword: newPasswordText.text!) {resp in
                switch (resp) {
                case .none:
                    print("change password sucess")
                    self.infoLabel.text = "success"
                    SwiftSpinner.show("success", animated: false)
                default:
                    print("change password failed: \(resp)")
                    SwiftSpinner.show("failed\n\(resp)", animated: false)
                }}
            delay(seconds: 0.8) {SwiftSpinner.hide()}
        default:
            print("change password validation failed: \(res)")
            SwiftSpinner.show("failed\n\(res)", animated: false)
            delay(seconds: 0.8) {SwiftSpinner.hide()}
        }
    }
}

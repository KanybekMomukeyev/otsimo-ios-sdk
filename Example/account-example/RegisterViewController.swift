//
//  RegisterViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

enum RegisterFormValidation {
    case Success
    case PasswordMismatch
    case ShortPassword
    case InvalidEmail
}



class RegisterViewController: UITableViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordReenterText: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validateFormValues() -> RegisterFormValidation {
        if passwordText.text! != passwordReenterText.text! {
            return .PasswordMismatch
        }
        if let count = passwordText.text?.characters.count {
            if count < 6 {
                return .ShortPassword
            }
        } else {
            return .ShortPassword
        }
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if let email = emailText.text {
            if !emailTest.evaluateWithObject(email) {
                return .InvalidEmail
            }
        } else {
            return .InvalidEmail
        }
        
        return .Success
    }
    
    func showError(message : String) {
        let alert = UIAlertController(title: "Invalid Input", message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func registerTouched(sender: UIButton) {
        let validateResult = validateFormValues()
        switch (validateResult) {
        case .Success:
            print("valid input")
        case .PasswordMismatch:
            showError("Passwords does not match")
            return
        case .ShortPassword:
            showError("Your password too short")
            return
        case .InvalidEmail:
            showError("invalid email")
            return
        }
        
        let language : String = NSBundle.mainBundle().preferredLocalizations.first!
        
        SwiftSpinner.show("registering...", animated: true)
        otsimo.register(RegistrationData(email: emailText.text!,
                password: passwordText.text!,
                firstName: firstNameText.text!,
                lastName: lastNameText.text!,
                language: language)) {repo in
            print("register finished")
            delay(seconds: 2.0, completion: {
                    SwiftSpinner.hide()
                })
            dispatch_async(dispatch_get_main_queue(), {
                    switch (repo) {
                    case .Success:
                        SwiftSpinner.show("registered", animated: false)
                        self.infoLabel.text = "registered \(otsimo.session?.profileID)"
                        print("successfully registered")
                    case .Error(let error):
                        SwiftSpinner.show("failed to\nregister", animated: false)
                        self.infoLabel.text = "failed \(error)"
                        print("register error: \(error)")
                    }})
        }
    }
    
}

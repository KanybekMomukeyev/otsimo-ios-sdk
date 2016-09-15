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
    case success
    case passwordMismatch
    case shortPassword
    case invalidEmail
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
            return .passwordMismatch
        }
        if let count = passwordText.text?.characters.count {
            if count < 6 {
                return .shortPassword
            }
        } else {
            return .shortPassword
        }
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if let email = emailText.text {
            if !emailTest.evaluate(with: email) {
                return .invalidEmail
            }
        } else {
            return .invalidEmail
        }
        
        return .success
    }
    
    func showError(_ message : String) {
        let alert = UIAlertController(title: "Invalid Input", message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func registerTouched(_ sender: UIButton) {
        let validateResult = validateFormValues()
        switch (validateResult) {
        case .success:
            print("valid input")
        case .passwordMismatch:
            showError("Passwords does not match")
            return
        case .shortPassword:
            showError("Your password too short")
            return
        case .invalidEmail:
            showError("invalid email")
            return
        }
        
        let language : String = Locale.current.identifier
        
        let _=SwiftSpinner.show("registering...", animated: true)
        otsimo.register(data: RegistrationData(email: emailText.text!,
                password: passwordText.text!,
                firstName: firstNameText.text!,
                lastName: lastNameText.text!,
                locale: language,
                country:"TR")) {repo in
            print("register finished")
            delay(seconds: 1.0) {SwiftSpinner.hide()}
            switch (repo) {
            case .success:
                SwiftSpinner.show("registered", animated: false)
                self.infoLabel.text = "registered \(otsimo.session?.profileID)"
                print("successfully registered")
            case .error(let error):
                SwiftSpinner.show("failed to\nregister", animated: false)
                self.infoLabel.text = "failed \(error)"
                print("register error: \(error)")
            }
        }
    }
    
}

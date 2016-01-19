//
//  ViewController.swift
//  account-example
//
//  Created by Sercan Değirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var footerText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginTouched(sender: UIButton) {
        print(emailText.text!, passwordText.text!)
        SwiftSpinner.show("logging in...", animated: true)
        otsimo.login(emailText.text!, password: passwordText.text!) {repo in
            print("login finished")
            delay(seconds: 1.0) {SwiftSpinner.hide()}
            switch (repo) {
            case .Success:
                print("successfully logged in")
                SwiftSpinner.show("successful", animated: false)
                self.footerText.text = "ID: \(otsimo.session!.profileID)"
            case .Error(let error):
                print("login error: \(error)")
                SwiftSpinner.show("failed", animated: false)
                self.footerText.text = "ERROR: \(error)"
            }
            
        }
    }
    
}


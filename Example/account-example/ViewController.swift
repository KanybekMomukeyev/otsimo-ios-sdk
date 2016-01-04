//
//  ViewController.swift
//  account-example
//
//  Created by Sercan Değirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK

class ViewController: UIViewController {
    var otsimo: Otsimo = Otsimo(config: ClientConfig.development("OdvHPcsgTcTnmYnvxJMVRDA4ifTy6a2zPTN6cnTUQ8g=@com.otsimo.sdk-example", host: nil))
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
        otsimo.login(emailText.text!, password: passwordText.text!) {repo in
            print("login finished")
            switch (repo) {
            case .Success:
                print("successfully logged in")
                self.footerText.text = "ID: \(self.otsimo.session!.profileID)"
            case .Error(let error):
                print("login error: \(error)")
                self.footerText.text = "ERROR: \(error)"
            }
        }
    }
    
    @IBAction func getProfileTouch(sender: UIButton) {
        otsimo.getProfile() {profile, error in
            switch (error) {
            case OtsimoError.None:
                self.footerText.text = "Profile: \(profile)"
                print("successfully get profile \(profile)")
            default:
                self.footerText.text = "ERROR: \(error)"
            }
        }
    }
}


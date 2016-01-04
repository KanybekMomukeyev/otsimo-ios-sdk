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

    var otsimo:Otsimo=Otsimo()
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginTouched(sender: UIButton) {
        print(emailText.text!,passwordText.text!)
        otsimo.login(emailText.text!, password: passwordText.text!)
    }
}


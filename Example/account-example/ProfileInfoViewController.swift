//
//  ProfileInfoViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK

class ProfileInfoViewController: UIViewController {
    @IBOutlet weak var outputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getProfile() {profile, error in
            switch (error) {
            case OtsimoError.None:
                self.outputLabel.text = "Profile: \(profile!)"
                print("successfully get profile \(profile!)")
            default:
                self.outputLabel.text = "ERROR: \(error)"
            }
            
        }
    }
}

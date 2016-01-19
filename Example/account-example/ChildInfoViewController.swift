//
//  ChildInfoViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 07/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit

class ChildInfoViewController: UIViewController {
    var childIdWillFetch: String = ""
    
    @IBOutlet weak var outputText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("fetching '\(childIdWillFetch)'")
        
        otsimo.getChild(childIdWillFetch) {child, err in
            switch (err) {
            case .None:
                self.outputText!.text = "\(child!)"
                self.navigationItem.title = child?.id_p
            default:
                self.outputText!.text = "ERROR: \(err)"
            }
        }
    }
    
}

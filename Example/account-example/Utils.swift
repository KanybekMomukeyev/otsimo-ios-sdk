//
//  Utils.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 20/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import UIKit

func showAlertWithText(text: String, onViewController vc: UIViewController, completion: (() -> Void)? = nil) {
    let controller = UIAlertController(title: "Oops", message: text, preferredStyle: UIAlertControllerStyle.Alert)
    let cancelAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
    controller.addAction(cancelAction)
    vc.presentViewController(controller, animated: true, completion: completion)
}
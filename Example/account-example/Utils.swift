//
//  Utils.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 20/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import UIKit

func showAlertWithText(_ text: String, onViewController vc: UIViewController, completion: (() -> Void)? = nil) {
    let controller = UIAlertController(title: "Oops", message: text, preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
    controller.addAction(cancelAction)
    vc.present(controller, animated: true, completion: completion)
}

func delay(seconds: Double, completion: @escaping () -> ()) {
    let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
    
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}

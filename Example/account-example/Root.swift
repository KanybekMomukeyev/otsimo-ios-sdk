//
//  Root.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoSDK


let clientID : String = "OdvHPcsgTcTnmYnvxJMVRDA4ifTy6a2zPTN6cnTUQ8g=@com.otsimo.sdk-example"
let devHost: String = "127.0.0.1"

var otsimo: Otsimo = Otsimo(config: ClientConfig.development(clientID, host: devHost))

func delay(seconds seconds: Double, completion: () -> ()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}
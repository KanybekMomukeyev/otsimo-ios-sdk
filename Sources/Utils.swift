//
//  Utils.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

func onMainThread(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), {() -> Void in
            closure()
        })
}
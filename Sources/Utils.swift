//
//  Utils.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

let analyticsQueue = dispatch_queue_create(
    "com.otsimo.iossdk.analytics", DISPATCH_QUEUE_CONCURRENT)

func onMainThread(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), {() -> Void in
            closure()
        })
}

public struct RegistrationData {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let language: String
    public init(email: String, password: String, firstName: String, lastName: String, language: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.language = language
    }
}


func versionToUrl(version: String) -> String {
    return version.stringByReplacingOccurrencesOfString(".", withString: "_")
}
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

let sessionQueue = dispatch_queue_create(
    "com.otsimo.iossdk.session", DISPATCH_QUEUE_CONCURRENT)

func onMainThread(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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

func createDispatchTimer(interval: UInt64, queue: dispatch_queue_t, handler: () -> Void) -> dispatch_source_t {
    let t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)

    if let timer = t {
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
        dispatch_source_set_event_handler(timer, handler)
        dispatch_resume(timer)
    }
    return t;
}
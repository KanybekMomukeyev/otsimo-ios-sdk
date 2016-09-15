//
//  Utils.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

let analyticsQueue = DispatchQueue(
    label: "com.otsimo.iossdk.analytics", attributes: DispatchQueue.Attributes.concurrent)

let sessionQueue = DispatchQueue(
    label: "com.otsimo.iossdk.session", attributes: DispatchQueue.Attributes.concurrent)

func onMainThread(_ closure: @escaping () -> ()) {
    DispatchQueue.main.async(execute: { () -> Void in
        closure()
    })
}

public struct RegistrationData {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let locale: String
    let country:String
    public init(email: String, password: String, firstName: String, lastName: String, locale: String,country:String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.locale = locale
        self.country = country
    }
}

func versionToUrl(_ version: String) -> String {
    return version.replacingOccurrences(of: ".", with: "_")
}

func createDispatchTimer(_ interval: UInt64, queue: DispatchQueue, handler: () -> Void) -> DispatchSource {
    let t = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)

    if let timer = t {
        timer.setTimer(start: DispatchTime.now(), interval: interval * NSEC_PER_SEC, leeway: 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
        timer.setEventHandler(handler: handler)
        timer.resume()
    }
    return t as! DispatchSource;
}

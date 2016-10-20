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

func versionToUrl(version: String) -> String {
    return version.replacingOccurrences(of: ".", with: "_")
}

func createDispatchTimer(interval: Int, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
    let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    timer.scheduleRepeating(deadline: .now(), interval: .seconds(interval), leeway: .seconds(1))
    timer.setEventHandler { 
        handler()
    }
    if #available(iOS 10.0, *) {
        timer.activate()
    } else {
        timer.resume()
    }
    return timer;
}

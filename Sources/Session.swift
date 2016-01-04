//
//  Session.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 02/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public class Session {
    var issuer: String = ""
    var clientID: String = ""
    var nonce: String = ""

    var isAuthenticated: Bool = false
    public func logout() {
    }
}
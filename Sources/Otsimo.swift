//
//  Otsimo.swift
//  OtsimoSDK
//
//  Created by Sercan Degirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import gRPC

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

public class Otsimo {
    public var session: Session?
    internal let connection: Connection
    
    public init(config: ClientConfig) {
        connection = Connection(config: config)
        recoverOldSessionIfExist()
    }
    
    public func login(email: String, password: String, handler: (res: TokenResult) -> Void) {
        connection.login(email, plainPassword: password) {res, ses in
            switch (res) {
            case .Success:
                self.session = ses
            default:
                print("login failed error:\(res)")
            }
            handler(res: res)
        }
    }
    
    public func register(data: RegistrationData, handler: (res: TokenResult) -> Void) {
        connection.register(data) {res, ses in
            switch (res) {
            case .Success:
                self.session = ses
            default:
                print("register failed error:\(res)")
            }
            handler(res: res)
        }
    }
    
    
    public func logout() {
        if let ses = session {
            ses.logout()
        }
    }
    
    public static func handleOpenURL(url: NSURL) {
        print("handleURL: ", url)
    }
    
    public func getProfile(handler: (OTSProfile?, OtsimoError) -> Void) {
        if let ses = session {
            if ses.profile != nil {
                // returns cached profile info
                handler(ses.profile, OtsimoError.None)
            } else {
                connection.getProfile(ses, handler: handler)
            }
        } else {
            handler(nil, .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func addChild(child: OTSChild, handler: (res: OtsimoError) -> Void) {
        if let ses = session {
            connection.addChild(ses, child: child, handler: handler)
        } else {
            handler(res: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    private func recoverOldSessionIfExist() {
        
    }
}
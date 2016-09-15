//
//  Otsimo+Account.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo: AccountApi {
    // Account API
    // login with given email and password. handler wil call on main queue
    public func login(_ email: String, password: String, handler: @escaping (_ res: TokenResult) -> Void) {
        if let connection = connection {
            connection.login(email, plainPassword: password) { res, ses in
                switch (res) {
                case .success:
                    self.session = ses
                    self.session?.save()
                default:
                    Log.error("login failed error:\(res)")
                }
                handler(res: res)
            }
        } else {
            handler(TokenResult.error(error: OtsimoError.notInitialized))
        }
    }

    public func login(_ connector: String, accessToken: String, handler: @escaping (_ res: TokenResult) -> Void) {
        if let connection = connection {
            connection.login(connector, accessToken: accessToken) { res, ses in
                switch (res) {
                case .success:
                    self.session = ses
                    self.session?.save()
                default:
                    Log.error("login failed error:\(res)")
                }
                handler(res: res)
            }
        } else {
            handler(TokenResult.error(error: OtsimoError.notInitialized))
        }
    }

    public func register(_ data: RegistrationData, handler: @escaping (_ res: TokenResult) -> Void) {
        if let connection = connection {
            connection.register(data) { res, ses in
                switch (res) {
                case .success:
                    self.session = ses
                    self.session?.save()
                default:
                    Log.error("register failed error:\(res)")
                }
                handler(res: res)
            }
        } else {
            handler(TokenResult.error(error: OtsimoError.notInitialized))
        }
    }

    public func logout() {
        if let ses = session {
            ses.logout()
            self.session = nil
        }
    }

    public func changeEmail(_ newEmail: String, handler: @escaping (OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.changeEmail(s, old: s.email, new: newEmail, handler: handler)
        }
    }

    public func changePassword(_ old: String, newPassword: String, handler: @escaping (OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.changePassword(s, old: old, new: newPassword, handler: handler)
        }
    }

    public func resetPassword(_ email: String, handler: (_ res: OtsimoError) -> Void) {
        if let connection = connection {
            connection.resetPassword(email, handler: handler)
        } else {
            handler(OtsimoError.notInitialized)
        }
    }

    public func userIdentities(_ handler: @escaping ([String: String], OtsimoError) -> Void) {
        self.isReady({ handler([String: String](), $0) }) { (c, s) in
            c.getIdentities(s, handler: handler)
        }
    }
}

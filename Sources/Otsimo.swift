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
    public func handleOpenURL(url: NSURL) {
        print("handleURL: ", url)
    }
    private func recoverOldSessionIfExist() {
        
    }
    // Account
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
    
    public func updateProfile(profile: OTSProfile, handler: (error: OtsimoError) -> Void) {
        if let ses = session {
            connection.updateProfile(ses, profile: profile, handler: handler)
        } else {
            handler(error: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func changeEmail(newEmail: String, handler: (OtsimoError) -> Void) {
        if let ses = session {
            connection.changeEmail(ses, old: ses.email, new: newEmail, handler: handler)
        } else {
            handler(.NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func changePassword(old: String, newPassword: String, handler: (OtsimoError) -> Void) {
        if let ses = session {
            connection.changePassword(ses, old: old, new: newPassword, handler: handler)
        } else {
            handler(.NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    // Profile
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
    
    // Child
    public func addChild(firstName: String, lastName: String, gender: OTSGender, birthDay: NSDate, language: String, handler: (res: OtsimoError) -> Void) {
        let child: OTSChild = OTSChild()
        child.fistName = firstName
        child.lastName = lastName
        child.gender = gender
        child.language = language
        child.birthDay = Int64(birthDay.timeIntervalSince1970)
        
        if let ses = session {
            connection.addChild(ses, child: child, handler: handler)
        } else {
            handler(res: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func getChild(id: String, handler: (res: OTSChild?, err: OtsimoError) -> Void) {
        if let ses = session {
            connection.getChild(ses, childId: id, handler: handler)
        } else {
            handler(res: nil, err: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func getChildren(handler: (res: [OTSChild], err: OtsimoError) -> Void) {
        if let ses = session {
            connection.getChildren(ses, handler: handler)
        } else {
            handler(res: [], err: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func addGameToChild(gameID: String, childID: String, index: Int32, settings: NSData, handler: (error: OtsimoError) -> Void) {
        let req = OTSGameEntryRequest()
        req.gameId = gameID
        req.childId = childID
        req.index = index
        req.settings = settings
        req.type = OTSGameEntryRequest_RequestType.Add
        if let ses = session {
            connection.updateGameEntry(ses, req: req, handler: handler)
        } else {
            handler(error: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: (error: OtsimoError) -> Void) {
        let req = OTSGameEntryRequest()
        req.gameId = gameID
        req.childId = childID
        if activate {
            req.type = OTSGameEntryRequest_RequestType.Activate
        } else {
            req.type = OTSGameEntryRequest_RequestType.Deactivate
        }
        if let ses = session {
            connection.updateGameEntry(ses, req: req, handler: handler)
        } else {
            handler(error: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func updateSettings(gameID: String, childID: String, settings: NSData, handler: (error: OtsimoError) -> Void) {
        let req = OTSGameEntryRequest()
        req.gameId = gameID
        req.childId = childID
        req.settings = settings
        req.type = OTSGameEntryRequest_RequestType.Settings
        if let ses = session {
            connection.updateGameEntry(ses, req: req, handler: handler)
        } else {
            handler(error: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    
    public func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: (error: OtsimoError) -> Void) {
        let req = OTSGameEntryRequest()
        req.gameId = gameID
        req.childId = childID
        req.index = index
        req.type = OTSGameEntryRequest_RequestType.Index
        if let ses = session {
            connection.updateGameEntry(ses, req: req, handler: handler)
        } else {
            handler(error: .NotLoggedIn(message: "not logged in, session is nil"))
        }
    }
    // Game
    public func getGame(id: String, handler: (res: OTSGameRelease?, err: OtsimoError) -> Void) {
        handler(res: nil, err: OtsimoError.ServiceError(message: "not implemented"))
    }
    
    public func getGameFromName(name: String, handler: (res: OTSGameRelease?, err: OtsimoError) -> Void) {
        handler(res: nil, err: OtsimoError.ServiceError(message: "not implemented"))
    }
    
    // Search
    public func searchGame(query: String, handler: (res: OTSSearchResponse?, err: OtsimoError) -> Void) {
        handler(res: nil, err: OtsimoError.ServiceError(message: "not implemented"))
    }
}
//
//  Otsimo+Child.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo: ChildApi {
    public func addChild(firstName: String, lastName: String, gender: OTSGender, birthDay: NSDate, language: String, handler: (res: OtsimoError) -> Void) {
        if let connection = connection {
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
        } else {
            handler(res: OtsimoError.NotInitialized)
        }
    }
    
    public func getChild(id: String, handler: (res: OTSChild?, err: OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.getChild(ses, childId: id, handler: handler)
            } else {
                handler(res: nil, err: .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(res: nil, err: OtsimoError.NotInitialized)
        }
    }
    
    public func getChildren(handler: (res: [OTSChild], err: OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.getChildren(ses, handler: handler)
            } else {
                handler(res: [], err: .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(res: [], err: .NotInitialized)
        }
    }
    
    public func addGameToChild(gameID: String, childID: String, index: Int32, settings: NSData, handler: (error: OtsimoError) -> Void) {
        if let connection = connection {
            
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
        } else {
            handler(error: .NotInitialized)
        }
    }
    
    public func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: (error: OtsimoError) -> Void) {
        if let connection = connection {
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
        } else {
            handler(error: .NotInitialized)
        }
    }
    
    public func updateSettings(gameID: String, childID: String, settings: NSData, handler: (error: OtsimoError) -> Void) {
        if let connection = connection {
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
        } else {
            handler(error: .NotInitialized)
        }
    }
    
    public func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: (error: OtsimoError) -> Void) {
        if let connection = connection {
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
        } else {
            handler(error: .NotInitialized)
        }
    }
    
}
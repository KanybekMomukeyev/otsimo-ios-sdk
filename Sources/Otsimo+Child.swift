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

    public func updateChild(childID: String, child: OTSChild, handler: (error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.updateChild(s, id: childID, parentID: s.profileID, child: child, handler: handler)
        }
    }

    public func addChild(child:OTSChild, handler: (res: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.addChild(s, child: child, handler: handler)
        }
    }

    public func getChild(id: String, handler: (res: OTSChild?, err: OtsimoError) -> Void) {
        self.isReady({ handler(res: nil, err: $0) }) { c, s in
            c.getChild(s, childId: id, handler: handler)
        }
    }

    public func getChildren(handler: (res: [OTSChild], err: OtsimoError) -> Void) {
        self.isReady({ handler(res: [], err: $0) }) { c, s in
            c.getChildren(s, handler: handler)
        }
    }

    public func addGameToChild(gameID: String, childID: String, index: Int32, settings: NSData, handler: (error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            req.index = index
            req.settings = settings
            req.type = OTSGameEntryRequest_RequestType.Add
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: (error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            if activate {
                req.type = OTSGameEntryRequest_RequestType.Activate
            } else {
                req.type = OTSGameEntryRequest_RequestType.Deactivate
            }
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func updateSettings(gameID: String, childID: String, settings: NSData, handler: (error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            req.settings = settings
            req.type = OTSGameEntryRequest_RequestType.Settings
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: (error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            req.index = index
            req.type = OTSGameEntryRequest_RequestType.Index
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func enableSound(childID: String, enable: Bool, handler: (error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSSoundEnableRequest()
            req.childId = childID
            req.enable = enable
            req.profileId = s.profileID
            c.updateChildAppSound(s, req: req, handler: handler)
        }
    }
}

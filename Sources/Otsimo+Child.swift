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

    public func updateChild(childID: String, child: OTSChild, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.updateChild(s, id: childID, parentID: s.profileID, child: child, handler: handler)
        }
    }

    public func addChild(child:OTSChild, handler: @escaping (_ res: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.addChild(s, child: child, handler: handler)
        }
    }

    public func getChild(childID: String, handler: @escaping (_ res: OTSChild?, _ err: OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            c.getChild(s, childId: childID, handler: handler)
        }
    }

    public func getChildren(handler: @escaping (_ res: [OTSChild], _ err: OtsimoError) -> Void) {
        self.isReady({ handler([], $0) }) { c, s in
            c.getChildren(s, handler: handler)
        }
    }

    public func addGameToChild(gameID: String, childID: String, index: Int32, settings: Data, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            req.index = index
            req.settings = settings
            req.type = OTSGameEntryRequest_RequestType.add
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            if activate {
                req.type = OTSGameEntryRequest_RequestType.activate
            } else {
                req.type = OTSGameEntryRequest_RequestType.deactivate
            }
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func updateSettings(gameID: String, childID: String, settings: Data, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            req.settings = settings
            req.type = OTSGameEntryRequest_RequestType.settings
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSGameEntryRequest()
            req.gameId = gameID
            req.childId = childID
            req.index = index
            req.type = OTSGameEntryRequest_RequestType.index
            c.updateGameEntry(s, req: req, handler: handler)
        }
    }

    public func enableSound(childID: String, enable: Bool, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            let req = OTSSoundEnableRequest()
            req.childId = childID
            req.enable = enable
            req.profileId = s.profileID
            c.updateChildAppSound(s, req: req, handler: handler)
        }
    }
}

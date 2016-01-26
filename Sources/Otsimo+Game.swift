//
//  Otsimo+Game.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo: GameApi {
    // Game
    public func getGame(id: String, handler: (Game?, error: OtsimoError) -> Void) {
        getGameRelease(id, version: nil, onlyProduction: Otsimo.sharedInstance.useProductionGames) {resp, error in
            if let gr = resp {
                handler(Game(gameRelease: gr), error: .None)
            } else {
                handler(nil, error: error)
            }
        }
    }
    
    public func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: (OTSGameRelease?, error: OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.getGameRelease(ses, gameID: id, version: version, onlyProduction: onlyProduction, handler: handler)
            } else {
                handler(nil, error: .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(nil, error: OtsimoError.NotInitialized)
        }
    }
    
    public func getAllGames(handler: (Game?, done: Bool, error: OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.getAllGamesStream(ses) {li, done, error in
                    if let item = li {
                        handler(Game(listItem: item), done: done, error: error)
                    } else {
                        handler(nil, done: done, error: error)
                    }
                }
            } else {
                handler(nil, done: true, error: .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(nil, done: true, error: OtsimoError.NotInitialized)
        }
    }
}
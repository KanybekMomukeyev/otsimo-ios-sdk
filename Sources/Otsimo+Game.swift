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
        Otsimo.sharedInstance.cache.fetchGame(id) { game, isExpired in
            if game != nil && !isExpired {
                handler(game, error: .None)
                return
            }

            self.getGameRelease(id, version: nil, onlyProduction: Otsimo.sharedInstance.onlyProduction) { resp, error in
                if let gr = resp {
                    let game = Game(gameRelease: gr)
                    game.cache()
                    handler(game, error: .None)
                } else {
                    if let game = game {
                        handler(game, error: OtsimoError.ExpiredValue)
                    } else {
                        handler(nil, error: error)
                    }
                }
            }
        }
    }

    public func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: (OTSGameRelease?, error: OtsimoError) -> Void) {
        self.isReady({ handler(nil, error: $0)}) { c, s in
            c.getGameRelease(s, gameID: id, version: version, onlyProduction: onlyProduction, handler: handler)
        }
    }

    public func getAllGames(handler: (Game?, done: Bool, error: OtsimoError) -> Void) {
        self.isReady({ handler(nil, done: true, error: $0)}) { c, s in
            c.getAllGamesStream(s) { li, done, error in
                if let item = li {
                    Otsimo.sharedInstance.cache.fetchGame(item.gameId) { game, isExpired in
                        if let game = game {
                            if game.productionVersion == item.productionVersion {
                                handler(game, done: done, error: error)
                            } else {
                                handler(Game(listItem: item), done: done, error: error)
                            }
                        } else {
                            handler(Game(listItem: item), done: done, error: error)
                        }
                    }
                } else {
                    handler(nil, done: done, error: error)
                }
            }
        }
    }

    public func gamesLatestVersions(gameIDs: [String], handler: (result: [OTSGameAndVersion], error: OtsimoError) -> Void) {
        self.isReady({ handler(result: [], error: $0)}) { c, s in
            c.gamesLatestVersions(s, gameIDs: gameIDs, handler: handler)
        }
    }
}
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
    public func getGame(_ id: String, handler: @escaping (Game?, _ error: OtsimoError) -> Void) {
        Otsimo.sharedInstance.cache.fetchGame(id) { game, isExpired in
            if game != nil {
                if isExpired {
                    Log.debug("GameApi:getGame: found game but it expired")
                }
                handler(game, error: .none)
                return
            }

            self.getGameRelease(id, version: nil, onlyProduction: Otsimo.sharedInstance.onlyProduction) { resp, error in
                if let gr = resp {
                    let game = Game(gameRelease: gr)
                    game.cache()
                    handler(game, error: .none)
                } else {
                    if let game = game {
                        Log.debug("GameApi:getGame: failed to get game, using cached value,err=\(error)")
                        handler(game, error: OtsimoError.expiredValue)
                    } else {
                        Log.debug("GameApi:getGame: failed to get game and no cache data,err=\(error)")
                        handler(nil, error: error)
                    }
                }
            }
        }
    }

    public func getGameRelease(_ id: String, version: String?, onlyProduction: Bool?, handler: @escaping (OTSGameRelease?, _ error: OtsimoError) -> Void) {
        self.isReady({ handler(nil, error: $0) }) { c, s in
            c.getGameRelease(s, gameID: id, version: version, onlyProduction: onlyProduction, handler: handler)
        }
    }

    public func getAllGames(_ language:String?, handler: @escaping (Game?, _ done: Bool, _ error: OtsimoError) -> Void) {
        self.isReady({ handler(nil, done: true, error: $0) }) { c, s in
            c.getAllGamesStream(language, session: s) { li, done, error in
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

    public func gamesLatestVersions(_ gameIDs: [String], handler: @escaping (_ result: [OTSGameAndVersion], _ error: OtsimoError) -> Void) {
        self.isReady({ handler(result: [], error: $0) }) { c, s in
            c.gamesLatestVersions(s, gameIDs: gameIDs, handler: handler)
        }
    }
}

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
    public func getGame(id: String, handler: @escaping (Game?, _ error: OtsimoError) -> Void) {
        Otsimo.sharedInstance.cache.fetchGame(id) { game, isExpired in
            if game != nil {
                if isExpired {
                    Log.debug("GameApi:getGame: found game but it expired")
                }
                handler(game, .none)
                return
            }

            self.getGameRelease(id:id, version: nil, onlyProduction: Otsimo.sharedInstance.onlyProduction) { resp, error in
                if let gr = resp {
                    let game = Game(gameRelease: gr)
                    game.cache()
                    handler(game, .none)
                } else {
                    if let game = game {
                        Log.debug("GameApi:getGame: failed to get game, using cached value,err=\(error)")
                        handler(game, OtsimoError.expiredValue)
                    } else {
                        Log.debug("GameApi:getGame: failed to get game and no cache data,err=\(error)")
                        handler(nil, error)
                    }
                }
            }
        }
    }

    public func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: @escaping (OTSGameRelease?, _ error: OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            c.getGameRelease(s, gameID: id, version: version, onlyProduction: onlyProduction, handler: handler)
        }
    }

    public func getAllGames(language:String?, handler: @escaping (Game?, _ done: Bool, _ error: OtsimoError) -> Void) {
        self.isReady({ handler(nil, true, $0) }) { c, s in
            c.getAllGamesStream(language, session: s) { li, done, error in
                if let item = li {
                    Otsimo.sharedInstance.cache.fetchGame(item.gameId) { game, isExpired in
                        if let game = game {
                            if game.productionVersion == item.productionVersion {
                                handler(game, done, error)
                            } else {
                                handler(Game(listItem: item), done, error)
                            }
                        } else {
                            handler(Game(listItem: item), done, error)
                        }
                    }
                } else {
                    handler(nil, done, error)
                }
            }
        }
    }

    public func gamesLatestVersions(gameIDs: [String], handler: @escaping (_ result: [OTSGameAndVersion], _ error: OtsimoError) -> Void) {
        self.isReady({ handler( [],  $0) }) { c, s in
            c.gamesLatestVersions(s, gameIDs: gameIDs, handler: handler)
        }
    }
}

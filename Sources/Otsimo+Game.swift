//
//  Otsimo+Game.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

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

            self.getGameRelease(id: id, version: nil, onlyProduction: Otsimo.sharedInstance.onlyProduction) { resp, error in
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

    public func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: @escaping (Apipb_GameRelease?, _ error: OtsimoError) -> Void) {
        self.isReadyWithMaybeSession({ handler(nil, $0) }) { c, session in
            c.getGameRelease(session, gameID: id, version: version, onlyProduction: onlyProduction, handler: handler)
        }
    }

    public func getAllGames(language: String?, handler: @escaping ([Game], OtsimoError) -> Void) {
        var req = Apipb_GetAllGamesReq()
        if let lang = language {
            req.language = lang
        }
        let RPC = Otsimo.sharedInstance.registryService!.getAllGames(req) { (res, err) in
            if let err = err {
                handler([], OtsimoError.general(message: err.localizedDescription))
                return
            }
            var games = [Game]()
            for g in res!.games {
                let game = Game(gameRelease: g)
                games.append(game)
                game.cache()
            }
            handler(games, OtsimoError.none)
        }
        RPC.start()
    }

    public func gamesLatestVersions(gameIDs: [String], handler: @escaping (_ result: [Apipb_GameAndVersion], _ error: OtsimoError) -> Void) {
        self.isReadyWithMaybeSession({ handler( [], $0) }) { (c, session) in
            c.gamesLatestVersions(session, gameIDs: gameIDs, handler: handler)
        }
    }

    public func gamesWithVersions(language: String?, gameAndVersions: [String: String], handler: @escaping([Game], OtsimoError) -> Void) {
        var req = Apipb_GetAllGamesReq()
        if let lang = language {
            req.language = lang
        }
        for a in gameAndVersions {
            var gv = Apipb_GameAndVersion()
            gv.gameId = a.key
            gv.version = a.value
            req.games.append(gv)
        }
        let RPC = Otsimo.sharedInstance.registryService!.getAllGames(req) { (res, err) in
            if let err = err {
                handler([], OtsimoError.general(message: err.localizedDescription))
                return
            }
            var games = [Game]()
            for g in res!.games {
                let game = Game(gameRelease: g)
                games.append(game)
                game.cache()
            }
            handler(games, OtsimoError.none)
        }
        RPC.start()
    }
}

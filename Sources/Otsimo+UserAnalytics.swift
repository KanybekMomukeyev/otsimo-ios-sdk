//
//  Otsimo+UserAnalytics.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 15/02/2017.
//  Copyright © 2017 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo {
    func gamePlayingDuration(req: Apipb_GamePlayingRequest, handler: @escaping (Apipb_GamePlayingReply?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            let RPC = c.simplifiedAnalytics.gamePlayingDuration(req) { response, error in
                if let response = response {
                    onMainThread { handler(response, OtsimoError.none) }
                } else {
                    onMainThread { handler(nil,OtsimoError.serviceError(message: "\(error)")) }
                }
            }
            s.getAuthorizationHeader { header, err in
                switch (err) {
                case .none:
                    RPC.oauth2AccessToken = header
                    RPC.start()
                default:
                    handler(nil,err)
                }
            }
        }
    }

    func gameSuccessFailure(req: Apipb_GamePlayingRequest, handler: @escaping (Apipb_GamePlayingReply?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            let RPC = c.simplifiedAnalytics.gameSuccessFailure(req) { response, error in
                if let response = response {
                    onMainThread { handler(response, OtsimoError.none) }
                } else {
                    onMainThread { handler(nil,OtsimoError.serviceError(message: "\(error)")) }
                }
            }
            s.getAuthorizationHeader { header, err in
                switch (err) {
                case .none:
                    RPC.oauth2AccessToken = header
                    RPC.start()
                default:
                    handler(nil,err)
                }
            }
        }
    }
}

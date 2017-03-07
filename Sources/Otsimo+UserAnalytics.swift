//
//  Otsimo+UserAnalytics.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 15/02/2017.
//  Copyright © 2017 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo {
   open func gamePlayingDuration(req: OTSGamePlayingRequest, handler: @escaping (OTSGamePlayingReply?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            let RPC = c.simplifiedAnalytics.rpcToGamePlayingDuration(with: req) { response, error in
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

   open func gameSuccessFailure(req: OTSGamePlayingRequest, handler: @escaping (OTSGamePlayingReply?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            let RPC = c.simplifiedAnalytics.rpcToGameSuccessFailure(with: req) { response, error in
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

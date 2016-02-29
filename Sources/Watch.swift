//
//  Watch.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import gRPC
import OtsimoApiGrpc

internal class Watch: WatchProtocol {

    private var connection: Connection
    private var isStarted: Bool
    private var session: Session?
    private var handler: ((watch: OTSWatchEvent) -> Void)?
    private var RPC: ProtoRPC!
    init(connection: Connection) {
        self.connection = connection
        isStarted = false
    }

    func start(session: Session, handler: (watch: OTSWatchEvent) -> Void) {
        let req = OTSWatchRequest()
        req.profileId = session.profileID

        self.session = session
        RPC = connection.watchService.RPCToWatchWithRequest(req, eventHandler: rpcHandler)
        RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"

        RPC.start()
        isStarted = true
    }

    func stop(error: NSError?) {
        if isStarted {
            RPC.cancel()
        }
        isStarted = false
    }

    func rpcHandler(done: Bool, response: OTSWatchResponse!, error: NSError!) {
        if let r = response {
            if r.hasEvent {
                if let h = handler {
                    h(watch: r.event)
                }
            }
        }
    }
}

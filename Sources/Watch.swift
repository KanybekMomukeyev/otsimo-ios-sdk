//
//  Watch.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import grpc
import OtsimoApiGrpc

internal class Watch: WatchProtocol {

    private var connection: Connection
    private var session: Session?
    private var handler: ((watch: OTSWatchEvent) -> Void)?
    private var RPC: GRPCProtoCall!

    private var timer: dispatch_source_t?

    init(connection: Connection) {
        self.connection = connection
    }

    func start(session: Session, handler: (watch: OTSWatchEvent) -> Void) {
        self.handler = handler
        let req = OTSWatchRequest()
        req.profileId = session.profileID

        self.session = session
        RPC = connection.watchService.RPCToWatchWithRequest(req, eventHandler: rpcHandler)
        session.getAuthorizationHeader() { h, e in
            switch (e) {
            case .None:
                self.RPC.oauth2AccessToken = h
                self.RPC.start()
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
    }

    func restart() {
        if let rpc = RPC {
            if rpc.state == GRXWriterState.Started {
                if let t = timer {
                    dispatch_source_cancel(t)
                    timer = nil
                    return
                }
            }
        }
        if RPC != nil {
            RPC.cancel()
        }
        let req = OTSWatchRequest()
        req.profileId = session!.profileID
        RPC = connection.watchService.RPCToWatchWithRequest(req, eventHandler: rpcHandler)
        session?.getAuthorizationHeader() { h, e in
            switch (e) {
            case .None:
                self.RPC.oauth2AccessToken = h
                self.RPC.start()
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
    }

    func stop(error: NSError?) {
        if let rpc = RPC {
            if rpc.state == GRXWriterState.Started {
                rpc.cancel()
            }
        }
    }

    func rpcHandler(done: Bool, response: OTSWatchResponse?, error: NSError?) {
        Log.debug("Watch RpcHandler: done=\(done), error=\(error), event=\(response)")
        if let r = response {
            if r.hasEvent {
                if let h = handler {
                    h(watch: r.event)
                }
            }
        }
        if done {
            if timer == nil {
                timer = createDispatchTimer(30, queue: analyticsQueue, handler: self.restart)
            }
        }
    }
}

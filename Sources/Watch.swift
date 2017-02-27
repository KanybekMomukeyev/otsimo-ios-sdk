//
//  Watch.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import GRPCClient

internal class Watch: WatchProtocol {

    fileprivate var connection: Connection
    fileprivate var session: Session?
    fileprivate var handler: ((_ watch: Apipb_WatchEvent) -> Void)?
    fileprivate var RPC: GrpcProtoCall<Apipb_WatchResponse>!

    fileprivate var timer: DispatchSourceTimer?

    init(connection: Connection) {
        self.connection = connection
    }

    func start(session: Session, handler: @escaping (_ watch: Apipb_WatchEvent) -> Void) {
        self.handler = handler
        var req = Apipb_WatchRequest()
        req.profileId = session.profileID

        self.session = session
        RPC = connection.watchService.watch(req, handler: rpcHandler)
        session.getAuthorizationHeader() { h, e in
            switch (e) {
            case .none:
                self.RPC.oauth2AccessToken = h
                self.RPC.start()
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
    }

    func restart() {
        if let rpc = RPC {
            if rpc.state == GRXWriterState.started {
                if let t = timer {
                    t.cancel()
                    timer = nil
                    return
                }
            }
        }
        if RPC != nil {
            RPC.cancel()
        }
        var req = Apipb_WatchRequest()
        req.profileId = session!.profileID
        RPC = connection.watchService.watch(req, handler: rpcHandler)
        session?.getAuthorizationHeader() { h, e in
            switch (e) {
            case .none:
                self.RPC.oauth2AccessToken = h
                self.RPC.start()
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
    }

    func stop(error: Error?) {
        if let rpc = RPC {
            if rpc.state == GRXWriterState.started {
                rpc.cancel()
            }
        }
    }

    func rpcHandler(done: Bool, response: Apipb_WatchResponse?, error: Error?) {
        Log.debug("Watch RpcHandler: done=\(done), error=\(error), event=\(response)")
        if let r = response {
            if r.hasEvent {
                if let h = handler {
                    h(r.event)
                }
            }
        }
        if done {
            if timer == nil {
                timer = createDispatchTimer(interval: 30, queue: analyticsQueue, handler: self.restart)
            }
        }
    }
}

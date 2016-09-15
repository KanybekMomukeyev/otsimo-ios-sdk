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

    fileprivate var connection: Connection
    fileprivate var session: Session?
    fileprivate var handler: ((_ watch: OTSWatchEvent) -> Void)?
    fileprivate var RPC: GRPCProtoCall!

    fileprivate var timer: DispatchSource?

    init(connection: Connection) {
        self.connection = connection
    }

    func start(_ session: Session, handler: @escaping (_ watch: OTSWatchEvent) -> Void) {
        self.handler = handler
        let req = OTSWatchRequest()
        req.profileId = session.profileID

        self.session = session
        RPC = connection.watchService.rpcToWatch(with: req, eventHandler: rpcHandler as! (Bool, OTSWatchResponse?, Error?) -> Void)
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
        let req = OTSWatchRequest()
        req.profileId = session!.profileID
        RPC = connection.watchService.rpcToWatch(with: req, eventHandler: rpcHandler as! (Bool, OTSWatchResponse?, Error?) -> Void)
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

    func stop(_ error: NSError?) {
        if let rpc = RPC {
            if rpc.state == GRXWriterState.started {
                rpc.cancel()
            }
        }
    }

    func rpcHandler(_ done: Bool, response: OTSWatchResponse?, error: NSError?) {
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
                timer = createDispatchTimer(30, queue: analyticsQueue, handler: self.restart)
            }
        }
    }
}

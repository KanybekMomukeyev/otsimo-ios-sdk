//
//  Watch.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

import OtsimoApiGrpc
import gRPC

internal class Watch: WatchProtocol{
    private var internalWriter: GRXBufferedPipe
    private var connection: Connection
    private var isStarted: Bool
    private var session: Session?
    private var handler:((watch:OTSWatchEvent)->Void)?
    
    init(connection: Connection) {
        internalWriter = GRXBufferedPipe()
        self.connection = connection
        isStarted = false
    }
    
    var writer: GRXWriter {
        return internalWriter
    }
        
    func start(session:Session,handler:(watch:OTSWatchEvent) -> Void) {
        internalWriter = GRXBufferedPipe()
        self.session = session
        let RPC : ProtoRPC = connection.watchService.RPCToWatchWithRequestsWriter(writer, eventHandler: rpcHandler)        
        RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
        RPC.startWithWriteable(internalWriter)
        isStarted = true
        
        let req = OTSWatchRequest()
        req.profileId = session.profileID
        req.type = OTSWatchRequest_WatchRequestType.Create
        internalWriter.writeValue(req)
    }
    
    func stop(error:NSError?){
        internalWriter.writesFinishedWithError(error)
    }

    func rpcHandler(done:Bool, response: OTSWatchResponse!, error:NSError!) {
        if let r = response{
            if r.hasEvent{
                if let h = handler{
                    h(watch: r.event)
                }
            }
        }
        print("rpcHandler \(response) \(error)")
    }
    
}

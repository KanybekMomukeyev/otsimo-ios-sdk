//
//  Analytics.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 16/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import gRPC

public protocol OtsimoAnalyticsProtocol{
    func customEvent(event: String, payload: [String : AnyObject])
    func customEvent(event: String, childID: String?, gameID: String?, payload: [String:AnyObject])
    func appEvent(event: String, payload: [String : AnyObject])
    func start(session:Session)
    func stop(error:NSError?)
}

internal class Analytics : OtsimoAnalyticsProtocol{
    private var internalWriter: GRXBufferedPipe
    private var connection: Connection
    private var isConnected: Bool
    private var device: OTSDeviceInfo
    private var session: Session?
    
    init(connection: Connection) {
        internalWriter = GRXBufferedPipe()
        self.connection = connection
        isConnected = false
        device = OTSDeviceInfo(os:"ios")
    }
    
    var writer: GRXWriter {
        return internalWriter
    }
    
   // var writable: GRXWriteableProtocol = GRXWriteable()
    
    func start(session:Session) {
        print("start analytics")
        
        internalWriter = GRXBufferedPipe()
        
        self.session = session
        let RPC : ProtoRPC = connection.listenerService.RPCToCustomEventWithRequestsWriter(writer, handler: rpcHandler)
        RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
        RPC.startWithWriteable(internalWriter)
    }
    
    func stop(error:NSError?){
        print("stop analytics")
        internalWriter.writesFinishedWithError(error)
    }
    
    func rpcHandler(response: OTSResponse!, error:NSError!) {
        print("rpcHandler \(response) \(error)")
    }
    
    func customEvent(event: String, payload: [String : AnyObject]) {
        customEvent(event, childID: nil, gameID: nil, payload: payload)
    }
    
    func customEvent(event: String, childID: String?, gameID: String?, payload: [String:AnyObject]){
        let e = OTSEvent()
        e.event = event
        e.appId = NSBundle.mainBundle().bundleIdentifier!
        e.childId = childID
        e.subId = gameID
        e.timestamp = Int64(NSDate().timeIntervalSince1970)
        e.deviceId = device.vendorId
        e.userId = session!.profileID
        e.payload = try? NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
        
        internalWriter.writeValue(e)
    }
    
    func appEvent(event: String, payload: [String : AnyObject]) {
        let aed = OTSAppEventData()
        aed.event = event
        aed.device = device
        aed.appId = NSBundle.mainBundle().bundleIdentifier!
        aed.timestamp = Int64(NSDate().timeIntervalSince1970)
        aed.payload = try? NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
        
        let RPC = connection.listenerService.RPCToAppEventWithRequest(aed){r,e in }
        RPC.start()
    }
}
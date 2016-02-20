//
//  Analytics.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 16/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import gRPC
import RealmSwift
import Foundation
import OtsimoApiGrpc

class AppEventCache: Object {
    dynamic var time: NSDate = NSDate()
    dynamic var data: NSData = NSData()
    
    static var realm : Results<AppEventCache>{
        return store.objects(AppEventCache)
    }
    
    static func add(d:OTSAppEventData){
        if let data = d.data(){
            let c = AppEventCache()
            c.data = data
            do {
                try store.write{
                    store.add(c)
                }
            }catch(let error){
                Log.error("failed to add AppEvent to db: \(error)")
            }
        }else{
            Log.error("failed to get data from AppEventData")
        }
    }
}


internal class Analytics : OtsimoAnalyticsProtocol{
    private var internalWriter: GRXBufferedPipe
    private var connection: Connection
    private var isStarted: Bool
    private var device: OTSDeviceInfo
    private var session: Session?
    private var timer: NSTimer?
    init(connection: Connection) {
        internalWriter = GRXBufferedPipe()
        self.connection = connection
        isStarted = false
        device = OTSDeviceInfo(os:"ios")
    }
    
    func start(session:Session) {
        internalWriter = GRXBufferedPipe()
        
        self.session = session
        let RPC : ProtoRPC = connection.listenerService.RPCToCustomEventWithRequestsWriter(internalWriter, handler: rpcHandler)
        
        RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
        RPC.requestHeaders["device"] = device.data()!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        
        RPC.startWithWriteable(internalWriter)
        isStarted = true
    }
    
    func stop(error:NSError?){
        internalWriter.writesFinishedWithError(error)
        isStarted = false
    }
    
    func rpcHandler(response: OTSResponse!, error:NSError!) {
        print("rpcHandler \(response) \(error)")
        isStarted = false
        timer = NSTimer(timeInterval: 60, target: self, selector: Selector("checkEvent"), userInfo: nil, repeats: true)
    }
    
    func checkEvent() {
        
    }
    
    func customEvent(event: String, payload: [String : AnyObject]) {
        customEvent(event, childID: nil, gameID: nil, payload: payload)
    }
    
    func customEvent(event: String, childID: String?, gameID: String?, payload: [String:AnyObject]){
        dispatch_barrier_async(analyticsQueue){
            if let session = self.session{
                let e = OTSEvent()
                e.event = event
                e.appId = NSBundle.mainBundle().bundleIdentifier!
                e.childId = childID
                e.subId = gameID
                e.timestamp = Int64(NSDate().timeIntervalSince1970)
                e.deviceId = self.device.vendorId
                e.userId = session.profileID
                e.payload = try? NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
                
                if self.internalWriter.state == GRXWriterState.Started{
                    self.internalWriter.writeValue(e)
                }else{
                    //todo add queue
                }
            }
        }
    }
    
    func appEvent(event: String, payload: [String : AnyObject]) {
        dispatch_async(analyticsQueue){
            let aed = OTSAppEventData()
            aed.event = event
            aed.device = self.device
            aed.appId = NSBundle.mainBundle().bundleIdentifier!
            aed.timestamp = Int64(NSDate().timeIntervalSince1970)
            aed.payload = try? NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
            
            let RPC = self.connection.listenerService.RPCToAppEventWithRequest(aed){r,e in
                if  e != nil{
                    AppEventCache.add(aed)
                }
            }
            RPC.start()
        }
    }
}
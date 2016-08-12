//
//  Analytics.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 16/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//
import Foundation
import RealmSwift
import OtsimoApiGrpc
import grpc

class AppEventCache: Object {
    dynamic var time: NSDate = NSDate()
    dynamic var data: NSData = NSData()

    func event() -> OTSAppEventData {
        return try! OTSAppEventData(data: self.data)
    }

    static func add(d: OTSAppEventData) {
        if let data = d.data() {
            let c = AppEventCache()
            c.data = data
            do {
                let eventRealm = try Realm()
                eventRealm.beginWrite()
                eventRealm.add(c)
                try eventRealm.commitWrite()
            } catch(let error) {
                Log.error("failed to delete AppEvent to db: \(error)")
            }
        } else {
            Log.error("failed to get data from AppEventData")
        }
    }

    static func removeEvent(event: AppEventCache, realm: Realm) {
        do {
            realm.beginWrite()
            realm.delete(event)
            try realm.commitWrite()
        } catch(let error) {
            Log.error("failed to delete AppEvent from db: \(error)")
        }
    }
}

class EventCache: Object {
    dynamic var time: NSDate = NSDate()
    dynamic var data: NSData = NSData()
    dynamic var id: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }

    func event() -> OTSEvent {
        return try! OTSEvent(data: self.data)
    }

    static func add(d: OTSEvent) {
        if let data = d.data() {
            let c = EventCache()
            c.data = data
            c.time = NSDate()
            c.id = d.eventId
            do {
                let eventRealm = try Realm()
                eventRealm.beginWrite()
                eventRealm.add(c)
                try eventRealm.commitWrite()
            } catch(let error) {
                Log.error("failed to add Event to db: \(error)")
            }
        } else {
            Log.error("failed to get data from EventData")
        }
    }

    static func removeEvent(event: EventCache, realm: Realm) {
        do {
            realm.beginWrite()
            realm.delete(event)
            try realm.commitWrite()
        } catch(let error) {
            Log.error("failed to delete Event from db: \(error)")
        }
    }

    static func remove(id: String) {
        do {
            let r = try Realm()
            let objs = r.objects(EventCache)
            if let a = objs.filter("id = %@", id).first {
                r.beginWrite()
                r.delete(a)
                try r.commitWrite()
            }
        } catch(let error) {
            Log.error("failed to add Event to db: \(error)")
        }
    }
}

internal class Analytics: OtsimoAnalyticsProtocol {
    private var internalWriter: GRXBufferedPipe
    private var connection: Connection
    private var isStartedBefore: Bool
    private var device: OTSDeviceInfo
    private var session: Session?
    private var timer: dispatch_source_t?
    private var RPC: GRPCProtoCall!

    init(connection: Connection) {
        internalWriter = GRXBufferedPipe()
        self.connection = connection
        isStartedBefore = false
        device = OTSDeviceInfo(os: "ios")
    }

    func start(session: Session) {
        internalWriter = GRXBufferedPipe()
        self.session = session
        Log.debug("start Analytics \(self.isStartedBefore)")
        session.getAuthorizationHeader() { h, e in
            switch (e) {
            case .None:
                let l = self.connection.listenerService.RPCToCustomEventWithRequestsWriter(self.internalWriter, eventHandler: self.rpcHandler)
                if l.state != .Started {
                    l.oauth2AccessToken = h
                    l.requestHeaders.setValue(self.device.data()!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn), forKey: "device")
                }
                l.start()
                self.RPC = l
                self.isStartedBefore = true
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
        timer = createDispatchTimer(60, queue: analyticsQueue, handler: checkState)
    }

    func restart() {
        if RPC != nil {
            RPC.cancel()
        }
        Log.debug("restart Analytics \(self.isStartedBefore)")
        internalWriter = GRXBufferedPipe()
        self.session!.getAuthorizationHeader() { h, e in
            switch (e) {
            case .None:
                let l = self.connection.listenerService.RPCToCustomEventWithRequestsWriter(self.internalWriter, eventHandler: self.rpcHandler)
                l.oauth2AccessToken = h
                l.requestHeaders.setValue(self.device.data()!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn), forKey: "device")
                l.start()
                self.RPC = l
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
    }

    func stopTimer() {
        if let t = timer {
            dispatch_source_cancel(t)
        }
        timer = nil
    }

    func stop(error: NSError?) {
        internalWriter.writesFinishedWithError(error)
        stopTimer()
    }

    func rpcHandler(done: Bool, response: OTSEventResponse?, err: NSError?) {
        if let resp = response {
            if resp.success {
                Log.debug("rpcHandler: \(resp.eventId) sent")
                dispatch_async(analyticsQueue) {
                    EventCache.remove(resp.eventId)
                }
            } else {
                Log.debug("rpcHandler: \(resp.eventId) failed")
            }
        }
        if done {
            Log.info("Done Listening, err=\(err)")
        }
    }

    func checkState() {
        switch internalWriter.state {
        case .Started:
            self.sendStoredEvents()
        case .NotStarted:
            if session != nil && self.isStartedBefore {
                restart()
            }
        case .Paused:
            Log.debug("Analytics Paused")
        case .Finished:
            if isStartedBefore {
                restart()
            }
        }
    }

    private func resendAppEvent(ev: OTSAppEventData) {
        Log.debug("resendAppEvent:\(ev.event) \(ev.eventId)")
        if ev.event != "" {
            ev.isResend = true
            let r = self.connection.listenerService.RPCToAppEventWithRequest(ev) { r, e in
                if e != nil {
                    dispatch_async(analyticsQueue) {
                        AppEventCache.add(ev)
                    }
                }
            }
            r.requestHeaders.setValue(self.connection.config.clientID, forKey: "client_id")
            r.start()
        }
    }

    private func sendStoredEvents() {
        Log.debug("sendStoredEvents called")
        dispatch_async(analyticsQueue) {
            let end = NSDate(timeIntervalSince1970: NSDate().timeIntervalSince1970 - 15)
            var eventRealm: Realm
            do {
                eventRealm = try Realm()
            } catch {
                Log.error("failed to create Realm instance inside sendStoredEvents")
                return
            }

            let objs = eventRealm.objects(EventCache).filter("time <= %@", end)

            for o in objs {
                Log.debug("sendStoredEvents->>\(o.id) is sending again")
                let ev = o.event()
                if ev.eventId != "" {
                    ev.isResend = true
                    self.internalWriter.writeValue(ev)
                } else {
                    EventCache.removeEvent(o, realm: eventRealm)
                }
            }
            let aobjs = eventRealm.objects(AppEventCache).filter("time <= %@", end)
            for o in aobjs {
                let ev = o.event()
                AppEventCache.removeEvent(o, realm: eventRealm)
                self.resendAppEvent(ev)
            }
        }
    }

    func customEvent(event: String, payload: [String: AnyObject]) {
        customEvent(event, childID: nil, game: nil, payload: payload)
    }

    func customEvent(event: String, childID: String?, game: OTSGameInfo?, payload: [String: AnyObject]) {
        dispatch_barrier_async(analyticsQueue) {
            if let session = self.session {
                let e = OTSEvent()
                e.event = event
                e.appId = NSBundle.mainBundle().bundleIdentifier!
                e.childId = childID
                e.game = game
                e.timestamp = Int64(NSDate().timeIntervalSince1970)
                e.device = self.device
                e.userId = session.profileID
                e.eventId = NSUUID().UUIDString
                e.isResend = false
                e.payload = try? NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
                EventCache.add(e)
                self.internalWriter.writeValue(e)
            }
        }
    }

    func appEvent(event: String, payload: [String: AnyObject]) {
        dispatch_async(analyticsQueue) {
            let aed = OTSAppEventData()
            aed.event = event
            aed.device = self.device
            aed.appId = NSBundle.mainBundle().bundleIdentifier!
            aed.timestamp = Int64(NSDate().timeIntervalSince1970)
            aed.payload = try? NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
            aed.eventId = NSUUID().UUIDString
            aed.isResend = false
            let RPC = self.connection.listenerService.RPCToAppEventWithRequest(aed) { r, e in
                if e != nil {
                    dispatch_async(analyticsQueue) {
                        AppEventCache.add(aed)
                    }
                }
            }
            RPC.requestHeaders.setValue(self.connection.config.clientID, forKey: "client_id")
            RPC.start()
        }
    }
}
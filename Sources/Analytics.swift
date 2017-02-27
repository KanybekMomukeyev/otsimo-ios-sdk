//
//  Analytics.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 16/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//
import Foundation
import RealmSwift
import GRPCClient

class AppEventCache: Object {
    dynamic var time: Date = Date()
    dynamic var data: Data = Data()

    func event() -> Apipb_AppEventData {
        return try! Apipb_AppEventData(protobuf: self.data)
    }

    static func add(_ d: Apipb_AppEventData) {
        do {
            let data = try d.serializeProtobuf()
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
        } catch {
            Log.error("failed to get data from AppEventData")
        }
    }

    static func removeEvent(_ event: AppEventCache, realm: Realm) {
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
    dynamic var time: Date = Date()
    dynamic var data: Data = Data()
    dynamic var id: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }

    func event() -> Apipb_Event {
        return try! Apipb_Event(protobuf: self.data)
    }

    static func add(_ d: Apipb_Event) {
        do{
            let data = try d.serializeProtobuf()
            let c = EventCache()
            c.data = data
            c.time = Date()
            c.id = d.eventId
            do {
                let eventRealm = try Realm()
                eventRealm.beginWrite()
                eventRealm.add(c)
                try eventRealm.commitWrite()
            } catch(let error) {
                Log.error("failed to add Event to db: \(error)")
            }
        }catch{
            Log.error("failed to get data from EventData")
        }
    }

    static func removeEvent(_ event: EventCache, realm: Realm) {
        do {
            realm.beginWrite()
            realm.delete(event)
            try realm.commitWrite()
        } catch(let error) {
            Log.error("failed to delete Event from db: \(error)")
        }
    }

    static func remove(_ id: String) {
        do {
            let r = try Realm()
            if let a = r.object(ofType: EventCache.self, forPrimaryKey: id) {
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
    fileprivate var internalWriter: GRXBufferedPipe
    fileprivate var connection: Connection
    fileprivate var isStartedBefore: Bool
    fileprivate var device: Apipb_DeviceInfo
    fileprivate var deviceB64: String
    fileprivate var session: Session?
    fileprivate var timer: DispatchSourceTimer?
    fileprivate var RPC: GRPCCall!

    init(connection: Connection) {
        internalWriter = GRXBufferedPipe()
        self.connection = connection
        isStartedBefore = false
        device = Apipb_DeviceInfo(os: "ios")
        deviceB64 = (try! device.serializeProtobuf()).base64EncodedString(options: .endLineWithCarriageReturn)
    }

    func start(session: Session) {
        internalWriter = GRXBufferedPipe()
        self.session = session
        Log.debug("start Analytics \(self.isStartedBefore)")
        
        let l = self.connection.listenerService.customEvent(self.internalWriter, handler: self.rpcHandler)
        if l.state != .started {
            l.requestHeaders.setValue(self.deviceB64, forKey: "device")
        }
        self.RPC = l
        self.isStartedBefore = true
        timer = createDispatchTimer(interval: 60, queue: analyticsQueue, handler: checkState)
        l.start()
    }

    func restart() {
        if RPC != nil {
            RPC.cancel()
        }
        Log.debug("restart Analytics \(self.isStartedBefore)")
        internalWriter = GRXBufferedPipe()
        let l = self.connection.listenerService.customEvent(self.internalWriter, handler: self.rpcHandler)
        l.requestHeaders.setValue(self.deviceB64, forKey: "device")
        l.start()
    }

    func stopTimer() {
        if let t = timer {
            t.cancel()
        }
        timer = nil
    }

    func stop(error: Swift.Error?) {
        internalWriter.writesFinishedWithError(error)
        stopTimer()
    }

    func rpcHandler(done: Bool, response: Apipb_EventResponse?, error: Swift.Error?) {
        if let resp = response {
            if resp.success {
                Log.debug("rpcHandler: \(resp.eventId) sent")
                analyticsQueue.async {
                    EventCache.remove(resp.eventId)
                }
            } else {
                Log.debug("rpcHandler: \(resp.eventId) failed")
            }
        }
        if done {
            Log.info("Done Listening, err=\(error)")
        }
    }

    func checkState() {
        switch internalWriter.state {
        case .started:
            self.sendStoredEvents()
        case .notStarted:
            if session != nil && self.isStartedBefore {
                restart()
            }
        case .paused:
            Log.debug("Analytics Paused")
        case .finished:
            if isStartedBefore {
                restart()
            }
        }
    }

    fileprivate func resendAppEvent(_ ev: Apipb_AppEventData) {
        var ev = ev
        Log.debug("resendAppEvent:\(ev.event) \(ev.eventId)")
        if ev.event != "" {
            ev.isResend = true
            let r = self.connection.listenerService.appEvent(ev) { r, e in
                if e != nil {
                    analyticsQueue.async {
                        AppEventCache.add(ev)
                    }
                }
            }
            r.requestHeaders.setValue(self.connection.config.clientID, forKey: "client_id")
            r.start()
        }
    }

    fileprivate func sendStoredEvents() {
        Log.debug("sendStoredEvents called")
        analyticsQueue.async {
            let end = NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - 15)
            var eventRealm: Realm
            do {
                eventRealm = try Realm()
            } catch {
                Log.error("failed to create Realm instance inside sendStoredEvents")
                return
            }

            let objs = eventRealm.objects(EventCache.self).filter(NSPredicate(format: "time <= %@", end))

            for o in objs {
                Log.debug("sendStoredEvents->>\(o.id) is sending again")
                var ev = o.event()
                if ev.eventId != "" {
                    ev.isResend = true
                    self.internalWriter.writeValue(ev)
                } else {
                    EventCache.removeEvent(o, realm: eventRealm)
                }
            }
            let aobjs = eventRealm.objects(AppEventCache.self).filter(NSPredicate(format: "time <= %@", end))
            for o in aobjs {
                let ev = o.event()
                
                AppEventCache.removeEvent(o, realm: eventRealm)
                self.resendAppEvent(ev)
            }
        }
    }

    func customEvent(event: String, payload: [String: AnyObject]) {
        customEvent(event: event, childID: nil, game: nil, payload: payload)
    }

    func customEvent(event: String, childID: String?, game:  Apipb_GameInfo?, payload: [String: AnyObject]) {
        analyticsQueue.async(flags: .barrier, execute: {
            if let session = self.session {
                var e =  Apipb_Event()
                e.event = event
                e.appId = Bundle.main.bundleIdentifier!
                if let cid = childID{
                    e.childId = cid
                }
                if let g = game{
                    e.game = g
                }
                e.timestamp = Int64(Date().timeIntervalSince1970)
                e.device = self.device
                e.userId = session.profileID
                e.eventId = UUID().uuidString
                e.isResend = false
                do{
                    e.payload = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions())
                }catch{
                }
                EventCache.add(e)
                self.internalWriter.writeValue(e)
            }
        })
    }

    func appEvent(event: String, payload: [String: AnyObject]) {
        analyticsQueue.async {
            var aed =  Apipb_AppEventData()
            aed.event = event
            aed.device = self.device
            aed.appId = Bundle.main.bundleIdentifier!
            aed.timestamp = Int64(Date().timeIntervalSince1970)
            do{
                aed.payload = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions())
            }catch{
            }
            aed.eventId = UUID().uuidString
            aed.isResend = false
            if let session = self.session {
                aed.userId = session.profileID
            }
            let RPC = self.connection.listenerService.appEvent(aed) { r, e in
                if e != nil {
                    analyticsQueue.async {
                        AppEventCache.add(aed)
                    }
                }
            }
            RPC.requestHeaders.setValue(self.connection.config.clientID, forKey: "client_id")
            RPC.start()
        }
    }
}

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
    dynamic var time: Date = Date()
    dynamic var data: Data = Data()

    func event() -> OTSAppEventData {
        return try! OTSAppEventData(data: self.data)
    }

    static func add(_ d: OTSAppEventData) {
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

    func event() -> OTSEvent {
        return try! OTSEvent(data: self.data)
    }

    static func add(_ d: OTSEvent) {
        if let data = d.data() {
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
        } else {
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
    fileprivate var device: OTSDeviceInfo
    fileprivate var session: Session?
    fileprivate var timer: DispatchSourceTimer?
    fileprivate var RPC: GRPCProtoCall!

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
            case .none:
                let l = self.connection.listenerService.rpcToCustomEvent(withRequestsWriter: self.internalWriter, eventHandler: self.rpcHandler)
                if l.state != .started {
                    l.oauth2AccessToken = h
                    l.requestHeaders.setValue(self.device.data()!.base64EncodedString(options: .endLineWithCarriageReturn), forKey: "device")
                }
                l.start()
                self.RPC = l
                self.isStartedBefore = true
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
        timer = createDispatchTimer(interval: 60, queue: analyticsQueue, handler: checkState)
    }

    func restart() {
        if RPC != nil {
            RPC.cancel()
        }
        Log.debug("restart Analytics \(self.isStartedBefore)")
        internalWriter = GRXBufferedPipe()
        self.session!.getAuthorizationHeader() { h, e in
            switch (e) {
            case .none:
                let l = self.connection.listenerService.rpcToCustomEvent(withRequestsWriter: self.internalWriter, eventHandler: self.rpcHandler)
                l.oauth2AccessToken = h
                l.requestHeaders.setValue(self.device.data()!.base64EncodedString(options: .endLineWithCarriageReturn), forKey: "device")
                l.start()
                self.RPC = l
            default:
                Log.error("failed to get authorization header, \(e)")
            }
        }
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

    func rpcHandler(done: Bool, response: OTSEventResponse?, error: Swift.Error?) {
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

    fileprivate func resendAppEvent(_ ev: OTSAppEventData) {
        Log.debug("resendAppEvent:\(ev.event) \(ev.eventId)")
        if ev.event != "" {
            ev.isResend = true
            let r = self.connection.listenerService.rpcToAppEvent(withRequest: ev) { r, e in
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

            let objs = eventRealm.objects(EventCache.self).filter(NSPredicate(format:"time <= %@", end))

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
            let aobjs = eventRealm.objects(AppEventCache.self).filter(NSPredicate(format:"time <= %@", end))
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

    func customEvent(event: String, childID: String?, game: OTSGameInfo?, payload: [String: AnyObject]) {
        analyticsQueue.async(flags: .barrier, execute: {
            if let session = self.session {
                let e = OTSEvent()
                e.event = event
                e.appId = Bundle.main.bundleIdentifier!
                e.childId = childID
                e.game = game
                e.timestamp = Int64(Date().timeIntervalSince1970)
                e.device = self.device
                e.userId = session.profileID
                e.eventId = UUID().uuidString
                e.isResend = false
                e.payload = try? JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions())
                EventCache.add(e)
                self.internalWriter.writeValue(e)
            }
        }) 
    }

    func appEvent(event: String, payload: [String: AnyObject]) {
        analyticsQueue.async {
            let aed = OTSAppEventData()
            aed.event = event
            aed.device = self.device
            aed.appId = Bundle.main.bundleIdentifier!
            aed.timestamp = Int64(Date().timeIntervalSince1970)
            aed.payload = try? JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions())
            aed.eventId = UUID().uuidString
            aed.isResend = false
            if let session = self.session {
                aed.userId = session.profileID
            }
            let RPC = self.connection.listenerService.rpcToAppEvent(withRequest: aed) { r, e in
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

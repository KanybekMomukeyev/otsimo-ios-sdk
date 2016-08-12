//
//  ApiTest.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoSDK
import Locksmith

class ApiTest {
    var title: String
    var segmentName: String
    var requiresAuth: Bool
    var providesAuth: Bool
    var handle: (() -> Void)?
    init(title: String, segmentName: String, requires: Bool, provides: Bool, handle: (() -> Void)?) {
        self.title = title
        self.segmentName = segmentName
        self.requiresAuth = requires
        self.providesAuth = provides
        self.handle = handle
    }
    convenience init(title: String, segmentName: String, requires: Bool, provides: Bool) {
        self.init(title: title, segmentName: segmentName, requires: requires, provides: provides, handle: nil)
    }
}

let apiTestScenes = [
    ApiTest(title: "Login", segmentName: "logintest", requires: false, provides: true),
    ApiTest(title: "Register", segmentName: "registertest", requires: false, provides: true),
    ApiTest(title: "Logout", segmentName: "", requires: true, provides: false, handle: otsimo.logout),
    ApiTest(title: "Profile Info", segmentName: "profileinfotest", requires: true, provides: false),
    ApiTest(title: "Profile Update", segmentName: "profileupdatetest", requires: true, provides: false),
    ApiTest(title: "Change Password", segmentName: "changepasswordtest", requires: true, provides: false),
    ApiTest(title: "Add Child", segmentName: "addchildtest", requires: true, provides: false),
    ApiTest(title: "Child List", segmentName: "getchildlisttest", requires: true, provides: false),
    ApiTest(title: "Game List", segmentName: "getgamelisttest", requires: true, provides: false),
    ApiTest(title: "Catalog", segmentName: "catalogtest", requires: true, provides: false),
    ApiTest(title: "-Wiki", segmentName: "wikitest", requires: true, provides: false),
    ApiTest(title: "-Statistics of a Single Game", segmentName: "stattest", requires: true, provides: false),
    ApiTest(title: "-Dashboard", segmentName: "dashboardtest", requires: true, provides: false),
]

let userIDKey = "OtsimoSDK-Session-UserID"
let emailKey = "OtsimoSDK-Session-Email"

func userDefaults(appGroup: String) -> NSUserDefaults {
    if appGroup == "" {
        return NSUserDefaults.standardUserDefaults()
    }
    if let d = NSUserDefaults(suiteName: appGroup) {
        return d
    }
    Log.error("could not get shared nsuserdefaults with suitename")
    return NSUserDefaults.standardUserDefaults()
}
struct OtsimoAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
    let email: String
    let jwt: String
    let refresh: String
    let tokentype: String
    let service = "Otsimo"
    let sharedKeyChain: String?
    var account: String { return email }
    var accessGroup: String? { return sharedKeyChain }

    var data: [String: AnyObject] {
        return ["jwt": jwt, "refresh": refresh, "tokentype": tokentype]
    }
}

func base64decode(input: String) -> NSData? {
    let rem = input.characters.count % 4

    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(count: amount, repeatedValue: Character("="))
    }

    let base64 = input.stringByReplacingOccurrencesOfString("-", withString: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
        .stringByReplacingOccurrencesOfString("_", withString: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending

    return NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions(rawValue: 0))
}

func newExpiredToken(jwt: String) -> String {
    let segments = jwt.componentsSeparatedByString(".")
    if segments.count != 3 {
        return jwt
    }
    let headerSegment = segments[0]
    let payloadSegment = segments[1]
    let signatureSegment = segments[2]
    let payloadData = base64decode(payloadSegment)
    var payload = (try? NSJSONSerialization.JSONObjectWithData(payloadData!, options: NSJSONReadingOptions(rawValue: 0))) as! Payload
    payload["exp"] = 10000
    let opts=NSJSONWritingOptions(rawValue: 0)
    let pas = try! NSJSONSerialization.dataWithJSONObject(payload, options: opts).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
    let newPayload = pas.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions(rawValue: 0), range: nil)
    .stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions(rawValue: 0), range: nil)
    .stringByReplacingOccurrencesOfString("+", withString: "-", options: NSStringCompareOptions(rawValue: 0), range: nil)
    return "\(headerSegment).\(newPayload).\(signatureSegment)"
}

func fakeToken(config: Configuration) {
    let defaults = userDefaults(config.appGroupName)
    guard let email = defaults.stringForKey(emailKey) else {
        Log.error("could not find any previous session email, need to login")
        return
    }
    let account = OtsimoAccount(email: email, jwt: "", refresh: "", tokentype: "", sharedKeyChain: nil)
    if let result = account.readFromSecureStore() {
        let accessToken = result.data?["jwt"] as! String
        let refreshToken = result.data?["refresh"] as! String
        let tokenType = result.data?["tokentype"] as! String
        let net = newExpiredToken(accessToken)
        print("OLD: \(accessToken) NEW: \(net)")
        let accountNew = OtsimoAccount(email: email, jwt: net, refresh: refreshToken, tokentype: tokenType, sharedKeyChain: nil)
        do { try accountNew.updateInSecureStore() }
        catch {
            Log.error("failed set fake token \(error) ")
        }
    }
}

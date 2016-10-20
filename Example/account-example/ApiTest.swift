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

func userDefaults(_ appGroup: String) -> UserDefaults {
    if appGroup == "" {
        return UserDefaults.standard
    }
    if let d = UserDefaults(suiteName: appGroup) {
        return d
    }
    Log.error("could not get shared nsuserdefaults with suitename")
    return UserDefaults.standard
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

    var data: [String: Any] {
        return ["jwt": jwt as AnyObject, "refresh": refresh as AnyObject, "tokentype": tokentype as AnyObject]
    }
}

func base64decode(_ input: String) -> Data? {
    let rem = input.characters.count % 4

    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: "=", count: amount)
    }

    let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "_", with: "/", options: NSString.CompareOptions(rawValue: 0), range: nil) + ending

    return Data(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
}

func newExpiredToken(_ jwt: String) -> String {
    let segments = jwt.components(separatedBy: ".")
    if segments.count != 3 {
        return jwt
    }
    let headerSegment = segments[0]
    let payloadSegment = segments[1]
    let signatureSegment = segments[2]
    let payloadData = base64decode(payloadSegment)
    var payload = (try? JSONSerialization.jsonObject(with: payloadData!, options: JSONSerialization.ReadingOptions(rawValue: 0))) as! Payload
    payload["exp"] = 10000 as AnyObject?
    let opts=JSONSerialization.WritingOptions(rawValue: 0)
    let pas = try! JSONSerialization.data(withJSONObject: payload, options: opts).base64EncodedString(options: .endLineWithCarriageReturn)
    
    
    let newPayload = pas.replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of:"/", with: "_")
        .replacingOccurrences(of:"+", with: "-")
    return "\(headerSegment).\(newPayload).\(signatureSegment)"
}

func fakeToken(_ config: Configuration) {
    let defaults = userDefaults(config.appGroupName)
    guard let email = defaults.string(forKey: emailKey) else {
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

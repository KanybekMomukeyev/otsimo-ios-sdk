//
//  ApiTest.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 05/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

class ApiTest {
    var title: String
    var segmentName : String
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
    ApiTest(title: "Get Child List", segmentName: "getchildlisttest", requires: true, provides: false),
    ApiTest(title: "Get Child", segmentName: "getchildlisttest", requires: true, provides: false),
    ApiTest(title: "-Update Child Game", segmentName: "updatechildgametest", requires: true, provides: false),
    ApiTest(title: "Get Game List", segmentName: "getgamelisttest", requires: true, provides: false),
    ApiTest(title: "-Game Settings", segmentName: "gamesettingstest", requires: true, provides: false),
    ApiTest(title: "-Wiki", segmentName: "wikitest", requires: true, provides: false),
    ApiTest(title: "Catalog", segmentName: "catalogtest", requires: true, provides: false),
    ApiTest(title: "-Statistics of a Single Game", segmentName: "stattest", requires: true, provides: false),
    ApiTest(title: "-Dashboard", segmentName: "dashboardtest", requires: true, provides: false),
]


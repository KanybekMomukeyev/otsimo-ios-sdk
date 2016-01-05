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
    init(title: String, segmentName: String, requires: Bool, provides: Bool) {
        self.title = title
        self.segmentName = segmentName
        self.requiresAuth = requires
        self.providesAuth = provides
    }
}


let apiTestScenes = [
    ApiTest(title: "Login", segmentName: "logintest", requires: false, provides: true),
    ApiTest(title: "Register", segmentName: "registertest", requires: false, provides: true),
    ApiTest(title: "Logout", segmentName: "logouttest", requires: true, provides: false),
    ApiTest(title: "Profile Info", segmentName: "profileinfotest", requires: true, provides: false),
    ApiTest(title: "Wiki", segmentName: "wikitest", requires: true, provides: false),
    ApiTest(title: "Add Child", segmentName: "addchildtest", requires: true, provides: false),
    ApiTest(title: "Get Child List", segmentName: "getchildlisttest", requires: true, provides: false),
    ApiTest(title: "Get Child", segmentName: "getchildtest", requires: true, provides: false),
    ApiTest(title: "Get Game", segmentName: "getgametest", requires: true, provides: false),
    ApiTest(title: "Game Settings", segmentName: "gamesettingstest", requires: true, provides: false),
    ApiTest(title: "Market", segmentName: "markettest", requires: true, provides: false),
    ApiTest(title: "Statistics of a Single Game", segmentName: "stattest", requires: true, provides: false),
    ApiTest(title: "Dashboard", segmentName: "dashboardtest", requires: true, provides: false),
]
//
//  AppDelegate.swift
//  account-example
//
//  Created by Sercan Değirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import Cronet
import grpc
import GRPCClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        var clusterDiscoveryUrl = "https://services.otsimo.xyz:30862"
        var clientSecret = ""
        Log.setLevel(LogLevel.debug)
        if let dict = keys {
            clientID = dict["OtsimoClientID"] as! String
            clientSecret = dict["OtsimoClientSecret"] as! String
            clusterDiscoveryUrl = dict["OtsimoClusterDiscoveryURL"] as! String
        }

        let options = Configuration(
            discovery: clusterDiscoveryUrl,
            environment: "staging",
            clientID: clientID,
            clientSecret: clientSecret,
            appGroupName: "",
            keychainName: ""
        )
        Cronet.setHttp2Enabled(true)
        Cronet.start()
        GRPCCall.useCronet(with: Cronet.getGlobalEngine())
        otsimo.sessionStatusChanged = onSessionStatusChanged
        fakeToken(options)
        Otsimo.config(options: options)

        return true
    }

    func onSessionStatusChanged(_ ses: Session?) {
        let (w, e) = otsimo.startWatch(callback: watchCallback)
        print("WatchCreate: \(w) \(e)")
    }

    func application(_ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any) -> Bool {

            if (url.scheme == "comotsimosdk_example") {
                otsimo.handleOpenURL(url)
            }
            return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

//
//  DeviceInfo.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 16/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import gRPC

extension OTSDeviceInfo{
    static func platform() -> String {
        var size : Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](count: Int(size), repeatedValue: 0)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String.fromCString(machine)!
    }
    
    convenience init(os:String){
        self.init()
        let device = UIDevice.currentDevice()
        let locale = NSLocale.currentLocale()
        let bundle = NSBundle.mainBundle()
        let infoDictionary = bundle.infoDictionary!
        
        if let ifv = device.identifierForVendor{
            vendorId = ifv.UUIDString
        }else{
            vendorId = ""
        }
        osName = os
        clientSdk = Otsimo.sdkVersion
        bundleIdentifier = infoDictionary["CFBundleIdentifier"] as! String
        bundleVersion = infoDictionary["CFBundleVersion"] as! String
        bundleShortVersion = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        languageCode = locale.objectForKey(NSLocaleLanguageCode) as! String
        countryCode  = locale.objectForKey(NSLocaleCountryCode) as! String
        systemVersion = device.systemVersion
        deviceType = device.model.stringByReplacingOccurrencesOfString(" ", withString: "")
        deviceName = OTSDeviceInfo.platform()
    }
}


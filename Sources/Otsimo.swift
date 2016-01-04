//
//  Otsimo.swift
//  OtsimoSDK
//
//  Created by Sercan Degirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import gRPC

public class Otsimo {

    public var session: Session?

    public init() {

    }

    //TODO don't do something like this
    public func login(email: String, password: String) -> LoginResult {
        let remoteHost = "192.168.1.103:18854"
        GRPCCall.useInsecureConnectionsForHost(remoteHost)
        
        let service = OTSApiService(host: remoteHost)
        
        let request = OTSGetProfileRequest()
        request.id_p = email

        service.getProfileWithRequest(request){ response, error in
            if let response = response {
                NSLog("1. Finished successfully with response:\n\(response)")
            } else {
                NSLog("1. Finished with error: \(error!)")
            }
        }

        return LoginResult()
    }

    public static func handleOpenURL(url: NSURL) {
        print("handleURL: ", url)
        
       
    }
}
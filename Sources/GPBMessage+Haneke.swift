//
//  GPBMessage+Haneke.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 28/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import Protobuf
import Haneke
import OtsimoApiGrpc

extension OTSCatalog : DataConvertible, DataRepresentable {
    public typealias Result = OTSCatalog
    
    public class func convertFromData(data: NSData) -> Result? {
        var error: NSError? = nil
        return parseFromData(data, error: &error)
    }
    
    public func asData() -> NSData! {
        return data()
    }
}
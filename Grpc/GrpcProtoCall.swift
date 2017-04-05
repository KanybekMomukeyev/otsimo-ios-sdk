//
//  SwitGrpcCall.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 27/02/2017.
//  Copyright © 2017 Otsimo. All rights reserved.
//

import GRPCClient
import SwiftProtobuf

open class GrpcProtoCall<T>: GRPCCall where T: SwiftProtobuf.Message {
    var _responseWriteable: GRXWriteable?

    convenience init(host: String,
                     method: GrpcProtoMethod,
                     requestsWriter: GRXWriter,
                     response: T.Type,
                     responsesWriteable: GRXWriteable) {

        let binaryWriter = requestsWriter.map { (value) -> Any? in
            // crash if user did not sent valid protobuf message       
            // swift bug: https://bugs.swift.org/browse/SR-3871
            return try!( value as AnyObject as! SwiftProtobuf.Message).serializedData()
        }

        self.init(host: host, path: method.httpPath, requestsWriter: binaryWriter)
        self._responseWriteable = GRXWriteable(valueHandler: { (value) in
            do {
                let parsed = try response.init(serializedData: value as! Data)
                responsesWriteable.writeValue(parsed)
            } catch (let error) {
                self.finishWithError(error)
            }
        }) { (err) in
            responsesWriteable.writesFinishedWithError(err)
        }
    }

    open func start() {
        self.start(with: self._responseWriteable)
        self._responseWriteable = nil
    }
}

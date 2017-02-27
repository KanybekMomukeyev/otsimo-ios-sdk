//
//  SwitGrpcCall.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 27/02/2017.
//  Copyright © 2017 Otsimo. All rights reserved.
//

import GRPCClient
import SwiftProtobuf

open class GrpcProtoCall<T>: GRPCCall where T: SwiftProtobuf.Message  {
    var _responseWriteable: GRXWriteable?
    
    convenience init(host: String,
                     method: GrpcProtoMethod,
                     requestsWriter: GRXWriter,
                     response: T.Type,
                     responsesWriteable: GRXWriteable) {
        
        let binaryWriter = requestsWriter.map { (value) -> Any? in
            if let v = value as? SwiftProtobuf.Message{
                do{
                    return try v.serializeProtobuf()
                }catch{
                    return nil
                }
            }
            return nil
        }
        
        self.init(host: host, path: method.httpPath, requestsWriter: binaryWriter)
        self._responseWriteable = GRXWriteable(valueHandler: { (value) in
            do{
                let parsed = try response.init(protobuf: value as! Data)
                responsesWriteable.writeValue(parsed)
            }catch (let error){
                self.finishWithError(error)
            }
        }){ (err) in
            responsesWriteable.writesFinishedWithError(err)
        }
    }
    
    func start() {
        self.start(grxwriteable: self._responseWriteable)
    }
    
    func start(grxwriteable: GRXWriteable!) {
        super.start(with: grxwriteable)
        self._responseWriteable = nil
    }
}

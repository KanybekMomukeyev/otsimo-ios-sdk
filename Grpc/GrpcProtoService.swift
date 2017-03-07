//
//  GrpcProtoService.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 27/02/2017.
//  Copyright © 2017 Otsimo. All rights reserved.
//

import Foundation
import SwiftProtobuf
import GRPCClient


public protocol GrpcInterceptor {
    var id: String { get }
    func intercept(_ call: GRPCCall)
}

open class GrpcProtoService {
    private let _packageName: String
    private let _serviceName: String
    private let _host: String
    private var _interceptors: [GrpcInterceptor]
    init(host: String, packageName: String, serviceName: String) {
        self._host = host
        self._packageName = packageName
        self._serviceName = serviceName
        self._interceptors = []
    }

    func RPC <T>(method: String,
                 requestsWriter: GRXWriter,
                 response: T.Type,
                 responsesWriteable: GRXWriteable) -> GrpcProtoCall<T>
    where T: SwiftProtobuf.Message {
        let m = GrpcProtoMethod(package: self._packageName, service: self._serviceName, method: method)
        let call = GrpcProtoCall(host: self._host,
                                 method: m,
                                 requestsWriter: requestsWriter,
                                 response: response,
                                 responsesWriteable: responsesWriteable)
        for i in self._interceptors {
            i.intercept(call)
        }
        return call
    }

    open func Register(interceptor: GrpcInterceptor) {
        self._interceptors.append(interceptor)
    }

    open func Unregister(interceptor: GrpcInterceptor) {
        let index = _interceptors.index { (i) -> Bool in
            return i.id == interceptor.id
        }
        if let i = index {
            _interceptors.remove(at: i)
        }
    }
}

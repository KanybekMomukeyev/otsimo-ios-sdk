// Code generated by protoc-gen-grpc-swift
// DO NOT EDIT!
import SwiftProtobuf
import GRPCClient


public class SearchService: GrpcProtoService {

    public convenience init(host: String) {
        self.init(host: host, packageName: "apipb", serviceName: "SearchService")
    }

    public func indexDatabase(_ request: Apipb_IndexRequest,
                           handler: @escaping (Apipb_Response?, Error?) -> Void) -> GrpcProtoCall<Apipb_Response> {
        let writable = GRXWriteable { (value, error) in
            handler(value as? Apipb_Response, error)
        }
        return RPC(method: "IndexDatabase",
                   requestsWriter: GRXWriter(value: request),
                   response: Apipb_Response.self,
                   responsesWriteable: writable!)
    }
	
    public func reindexAll(_ request: Apipb_IndexRequest,
                           handler: @escaping (Apipb_Response?, Error?) -> Void) -> GrpcProtoCall<Apipb_Response> {
        let writable = GRXWriteable { (value, error) in
            handler(value as? Apipb_Response, error)
        }
        return RPC(method: "ReindexAll",
                   requestsWriter: GRXWriter(value: request),
                   response: Apipb_Response.self,
                   responsesWriteable: writable!)
    }
	
    public func search(_ request: Apipb_SearchRequest,
                           handler: @escaping (Apipb_SearchResponse?, Error?) -> Void) -> GrpcProtoCall<Apipb_SearchResponse> {
        let writable = GRXWriteable { (value, error) in
            handler(value as? Apipb_SearchResponse, error)
        }
        return RPC(method: "Search",
                   requestsWriter: GRXWriter(value: request),
                   response: Apipb_SearchResponse.self,
                   responsesWriteable: writable!)
    }
	
}
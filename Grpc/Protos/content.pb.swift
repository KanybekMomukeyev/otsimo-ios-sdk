/*
 * DO NOT EDIT.
 *
 * Generated by the protocol buffer compiler.
 * Source: content.proto
 *
 */

import Foundation
import SwiftProtobuf


public struct Apipb_Content: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_Content"}
  public var protoMessageName: String {return "Content"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .same(proto: "slug", swift: "slug"),
    2: .same(proto: "title", swift: "title"),
    3: .same(proto: "language", swift: "language"),
    4: .same(proto: "date", swift: "date"),
    5: .same(proto: "draft", swift: "draft"),
    6: .unique(proto: "written_at", json: "writtenAt", swift: "writtenAt"),
    7: .same(proto: "author", swift: "author"),
    8: .same(proto: "category", swift: "category"),
    9: .same(proto: "url", swift: "url"),
    10: .same(proto: "weight", swift: "weight"),
    11: .same(proto: "keywords", swift: "keywords"),
    12: .unique(proto: "category_weight", json: "categoryWeight", swift: "categoryWeight"),
    13: .same(proto: "markdown", swift: "markdown"),
    14: .same(proto: "params", swift: "params"),
  ]


  public var slug: String = ""

  public var title: String = ""

  public var language: String = ""

  public var date: Int64 = 0

  public var draft: Bool = false

  public var writtenAt: String = ""

  public var author: String = ""

  public var category: String = ""

  public var url: String = ""

  public var weight: Int32 = 0

  public var keywords: [String] = []

  public var categoryWeight: Int32 = 0

  public var markdown: Data = Data()

  public var params: Dictionary<String,String> = [:]

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    switch protoFieldNumber {
    case 1: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &slug)
    case 2: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &title)
    case 3: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &language)
    case 4: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufInt64.self, value: &date)
    case 5: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: &draft)
    case 6: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &writtenAt)
    case 7: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &author)
    case 8: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &category)
    case 9: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &url)
    case 10: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: &weight)
    case 11: try setter.decodeRepeatedField(fieldType: SwiftProtobuf.ProtobufString.self, value: &keywords)
    case 12: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: &categoryWeight)
    case 13: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufBytes.self, value: &markdown)
    case 14: try setter.decodeMapField(fieldType: SwiftProtobuf.ProtobufMap<SwiftProtobuf.ProtobufString,SwiftProtobuf.ProtobufString>.self, value: &params)
    default: break
    }
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    if slug != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: slug, fieldNumber: 1)
    }
    if title != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: title, fieldNumber: 2)
    }
    if language != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: language, fieldNumber: 3)
    }
    if date != 0 {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufInt64.self, value: date, fieldNumber: 4)
    }
    if draft != false {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: draft, fieldNumber: 5)
    }
    if writtenAt != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: writtenAt, fieldNumber: 6)
    }
    if author != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: author, fieldNumber: 7)
    }
    if category != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: category, fieldNumber: 8)
    }
    if url != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: url, fieldNumber: 9)
    }
    if weight != 0 {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: weight, fieldNumber: 10)
    }
    if !keywords.isEmpty {
      try visitor.visitRepeatedField(fieldType: SwiftProtobuf.ProtobufString.self, value: keywords, fieldNumber: 11)
    }
    if categoryWeight != 0 {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: categoryWeight, fieldNumber: 12)
    }
    if markdown != Data() {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufBytes.self, value: markdown, fieldNumber: 13)
    }
    if !params.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf.ProtobufMap<SwiftProtobuf.ProtobufString,SwiftProtobuf.ProtobufString>.self, value: params, fieldNumber: 14)
    }
  }

  public func _protoc_generated_isEqualTo(other: Apipb_Content) -> Bool {
    if slug != other.slug {return false}
    if title != other.title {return false}
    if language != other.language {return false}
    if date != other.date {return false}
    if draft != other.draft {return false}
    if writtenAt != other.writtenAt {return false}
    if author != other.author {return false}
    if category != other.category {return false}
    if url != other.url {return false}
    if weight != other.weight {return false}
    if keywords != other.keywords {return false}
    if categoryWeight != other.categoryWeight {return false}
    if markdown != other.markdown {return false}
    if params != other.params {return false}
    return true
  }
}

// Request-Response

public struct Apipb_ContentListRequest: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_ContentListRequest"}
  public var protoMessageName: String {return "ContentListRequest"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .same(proto: "status", swift: "status"),
    2: .same(proto: "limit", swift: "limit"),
    3: .same(proto: "category", swift: "category"),
    4: .same(proto: "offset", swift: "offset"),
    5: .same(proto: "language", swift: "language"),
    6: .unique(proto: "only_html_url", json: "onlyHtmlUrl", swift: "onlyHtmlURL"),
    7: .same(proto: "sort", swift: "sort"),
    8: .same(proto: "order", swift: "order"),
    10: .unique(proto: "profile_id", json: "profileId", swift: "profileId"),
    11: .unique(proto: "client_version", json: "clientVersion", swift: "clientVersion"),
    12: .same(proto: "categories", swift: "categories"),
    13: .unique(proto: "except_categories", json: "exceptCategories", swift: "exceptCategories"),
  ]


  public enum ListStatus: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case both // = 0
    case onlyDraft // = 1
    case onlyApproved // = 2
    case UNRECOGNIZED(Int)

    public init() {
      self = .both
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .both
      case 1: self = .onlyDraft
      case 2: self = .onlyApproved
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public init?(name: String) {
      switch name {
      case "both": self = .both
      case "onlyDraft": self = .onlyDraft
      case "onlyApproved": self = .onlyApproved
      default: return nil
      }
    }

    public init?(jsonName: String) {
      switch jsonName {
      case "BOTH": self = .both
      case "ONLY_DRAFT": self = .onlyDraft
      case "ONLY_APPROVED": self = .onlyApproved
      default: return nil
      }
    }

    public init?(protoName: String) {
      switch protoName {
      case "BOTH": self = .both
      case "ONLY_DRAFT": self = .onlyDraft
      case "ONLY_APPROVED": self = .onlyApproved
      default: return nil
      }
    }

    public var rawValue: Int {
      get {
        switch self {
        case .both: return 0
        case .onlyDraft: return 1
        case .onlyApproved: return 2
        case .UNRECOGNIZED(let i): return i
        }
      }
    }

    public var json: String {
      get {
        switch self {
        case .both: return "\"BOTH\""
        case .onlyDraft: return "\"ONLY_DRAFT\""
        case .onlyApproved: return "\"ONLY_APPROVED\""
        case .UNRECOGNIZED(let i): return String(i)
        }
      }
    }

    public var hashValue: Int { return rawValue }

    public var debugDescription: String {
      get {
        switch self {
        case .both: return ".both"
        case .onlyDraft: return ".onlyDraft"
        case .onlyApproved: return ".onlyApproved"
        case .UNRECOGNIZED(let v): return ".UNRECOGNIZED(\(v))"
        }
      }
    }

  }

  public enum SortBy: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case weight // = 0
    case time // = 1
    case UNRECOGNIZED(Int)

    public init() {
      self = .weight
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .weight
      case 1: self = .time
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public init?(name: String) {
      switch name {
      case "weight": self = .weight
      case "time": self = .time
      default: return nil
      }
    }

    public init?(jsonName: String) {
      switch jsonName {
      case "WEIGHT": self = .weight
      case "TIME": self = .time
      default: return nil
      }
    }

    public init?(protoName: String) {
      switch protoName {
      case "WEIGHT": self = .weight
      case "TIME": self = .time
      default: return nil
      }
    }

    public var rawValue: Int {
      get {
        switch self {
        case .weight: return 0
        case .time: return 1
        case .UNRECOGNIZED(let i): return i
        }
      }
    }

    public var json: String {
      get {
        switch self {
        case .weight: return "\"WEIGHT\""
        case .time: return "\"TIME\""
        case .UNRECOGNIZED(let i): return String(i)
        }
      }
    }

    public var hashValue: Int { return rawValue }

    public var debugDescription: String {
      get {
        switch self {
        case .weight: return ".weight"
        case .time: return ".time"
        case .UNRECOGNIZED(let v): return ".UNRECOGNIZED(\(v))"
        }
      }
    }

  }

  public enum SortOrder: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case dsc // = 0
    case asc // = 1
    case UNRECOGNIZED(Int)

    public init() {
      self = .dsc
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .dsc
      case 1: self = .asc
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public init?(name: String) {
      switch name {
      case "dsc": self = .dsc
      case "asc": self = .asc
      default: return nil
      }
    }

    public init?(jsonName: String) {
      switch jsonName {
      case "DSC": self = .dsc
      case "ASC": self = .asc
      default: return nil
      }
    }

    public init?(protoName: String) {
      switch protoName {
      case "DSC": self = .dsc
      case "ASC": self = .asc
      default: return nil
      }
    }

    public var rawValue: Int {
      get {
        switch self {
        case .dsc: return 0
        case .asc: return 1
        case .UNRECOGNIZED(let i): return i
        }
      }
    }

    public var json: String {
      get {
        switch self {
        case .dsc: return "\"DSC\""
        case .asc: return "\"ASC\""
        case .UNRECOGNIZED(let i): return String(i)
        }
      }
    }

    public var hashValue: Int { return rawValue }

    public var debugDescription: String {
      get {
        switch self {
        case .dsc: return ".dsc"
        case .asc: return ".asc"
        case .UNRECOGNIZED(let v): return ".UNRECOGNIZED(\(v))"
        }
      }
    }

  }

  public var status: Apipb_ContentListRequest.ListStatus = Apipb_ContentListRequest.ListStatus.both

  public var limit: Int32 = 0

  public var category: String = ""

  public var offset: Int32 = 0

  public var language: String = ""

  public var onlyHtmlURL: Bool = false

  public var sort: Apipb_ContentListRequest.SortBy = Apipb_ContentListRequest.SortBy.weight

  public var order: Apipb_ContentListRequest.SortOrder = Apipb_ContentListRequest.SortOrder.dsc

  public var profileId: String = ""

  public var clientVersion: String = ""

  public var categories: [String] = []

  public var exceptCategories: [String] = []

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    switch protoFieldNumber {
    case 1: try setter.decodeSingularField(fieldType: Apipb_ContentListRequest.ListStatus.self, value: &status)
    case 2: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: &limit)
    case 3: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &category)
    case 4: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: &offset)
    case 5: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &language)
    case 6: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: &onlyHtmlURL)
    case 7: try setter.decodeSingularField(fieldType: Apipb_ContentListRequest.SortBy.self, value: &sort)
    case 8: try setter.decodeSingularField(fieldType: Apipb_ContentListRequest.SortOrder.self, value: &order)
    case 10: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &profileId)
    case 11: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &clientVersion)
    case 12: try setter.decodeRepeatedField(fieldType: SwiftProtobuf.ProtobufString.self, value: &categories)
    case 13: try setter.decodeRepeatedField(fieldType: SwiftProtobuf.ProtobufString.self, value: &exceptCategories)
    default: break
    }
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    if status != Apipb_ContentListRequest.ListStatus.both {
      try visitor.visitSingularField(fieldType: Apipb_ContentListRequest.ListStatus.self, value: status, fieldNumber: 1)
    }
    if limit != 0 {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: limit, fieldNumber: 2)
    }
    if category != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: category, fieldNumber: 3)
    }
    if offset != 0 {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: offset, fieldNumber: 4)
    }
    if language != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: language, fieldNumber: 5)
    }
    if onlyHtmlURL != false {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: onlyHtmlURL, fieldNumber: 6)
    }
    if sort != Apipb_ContentListRequest.SortBy.weight {
      try visitor.visitSingularField(fieldType: Apipb_ContentListRequest.SortBy.self, value: sort, fieldNumber: 7)
    }
    if order != Apipb_ContentListRequest.SortOrder.dsc {
      try visitor.visitSingularField(fieldType: Apipb_ContentListRequest.SortOrder.self, value: order, fieldNumber: 8)
    }
    if profileId != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: profileId, fieldNumber: 10)
    }
    if clientVersion != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: clientVersion, fieldNumber: 11)
    }
    if !categories.isEmpty {
      try visitor.visitRepeatedField(fieldType: SwiftProtobuf.ProtobufString.self, value: categories, fieldNumber: 12)
    }
    if !exceptCategories.isEmpty {
      try visitor.visitRepeatedField(fieldType: SwiftProtobuf.ProtobufString.self, value: exceptCategories, fieldNumber: 13)
    }
  }

  public func _protoc_generated_isEqualTo(other: Apipb_ContentListRequest) -> Bool {
    if status != other.status {return false}
    if limit != other.limit {return false}
    if category != other.category {return false}
    if offset != other.offset {return false}
    if language != other.language {return false}
    if onlyHtmlURL != other.onlyHtmlURL {return false}
    if sort != other.sort {return false}
    if order != other.order {return false}
    if profileId != other.profileId {return false}
    if clientVersion != other.clientVersion {return false}
    if categories != other.categories {return false}
    if exceptCategories != other.exceptCategories {return false}
    return true
  }
}

public struct Apipb_ContentListResponse: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_ContentListResponse"}
  public var protoMessageName: String {return "ContentListResponse"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .same(proto: "contents", swift: "contents"),
    2: .unique(proto: "asset_version", json: "assetVersion", swift: "assetVersion"),
  ]


  public var contents: [Apipb_Content] = []

  public var assetVersion: Int32 = 0

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    switch protoFieldNumber {
    case 1: try setter.decodeRepeatedMessageField(fieldType: Apipb_Content.self, value: &contents)
    case 2: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: &assetVersion)
    default: break
    }
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    if !contents.isEmpty {
      try visitor.visitRepeatedMessageField(value: contents, fieldNumber: 1)
    }
    if assetVersion != 0 {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufInt32.self, value: assetVersion, fieldNumber: 2)
    }
  }

  public func _protoc_generated_isEqualTo(other: Apipb_ContentListResponse) -> Bool {
    if contents != other.contents {return false}
    if assetVersion != other.assetVersion {return false}
    return true
  }
}

public struct Apipb_ContentGetRequest: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_ContentGetRequest"}
  public var protoMessageName: String {return "ContentGetRequest"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .same(proto: "slug", swift: "slug"),
  ]


  public var slug: String = ""

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    switch protoFieldNumber {
    case 1: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &slug)
    default: break
    }
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    if slug != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: slug, fieldNumber: 1)
    }
  }

  public func _protoc_generated_isEqualTo(other: Apipb_ContentGetRequest) -> Bool {
    if slug != other.slug {return false}
    return true
  }
}

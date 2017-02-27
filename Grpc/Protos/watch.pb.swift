/*
 * DO NOT EDIT.
 *
 * Generated by the protocol buffer compiler.
 * Source: watch.proto
 *
 */

import Foundation
import SwiftProtobuf


public struct Apipb_EmitRequest: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_EmitRequest"}
  public var protoMessageName: String {return "EmitRequest"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .unique(proto: "profile_id", json: "profileId", swift: "profileId"),
    2: .same(proto: "event", swift: "event"),
  ]

  private class _StorageClass {
    typealias ExtendedMessage = Apipb_EmitRequest
    var _profileId: String = ""
    var _event: Apipb_WatchEvent? = nil

    init() {}

    func decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
      switch protoFieldNumber {
      case 1: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &_profileId)
      case 2: try setter.decodeSingularMessageField(fieldType: Apipb_WatchEvent.self, value: &_event)
      default: break
      }
    }

    func traverse(visitor: SwiftProtobuf.Visitor) throws {
      if _profileId != "" {
        try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: _profileId, fieldNumber: 1)
      }
      if let v = _event {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }

    func isEqualTo(other: _StorageClass) -> Bool {
      if _profileId != other._profileId {return false}
      if _event != other._event {return false}
      return true
    }

    func copy() -> _StorageClass {
      let clone = _StorageClass()
      clone._profileId = _profileId
      clone._event = _event
      return clone
    }
  }

  private var _storage = _StorageClass()


  public var profileId: String {
    get {return _storage._profileId}
    set {_uniqueStorage()._profileId = newValue}
  }

  public var event: Apipb_WatchEvent {
    get {return _storage._event ?? Apipb_WatchEvent()}
    set {_uniqueStorage()._event = newValue}
  }
  public var hasEvent: Bool {
    return _storage._event != nil
  }
  public mutating func clearEvent() {
    return _storage._event = nil
  }

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    try _uniqueStorage().decodeField(setter: &setter, protoFieldNumber: protoFieldNumber)
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    try _storage.traverse(visitor: visitor)
  }

  public func _protoc_generated_isEqualTo(other: Apipb_EmitRequest) -> Bool {
    return _storage === other._storage || _storage.isEqualTo(other: other._storage)
  }

  private mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _storage.copy()
    }
    return _storage
  }
}

///  TODO add something    
public struct Apipb_EmitResponse: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_EmitResponse"}
  public var protoMessageName: String {return "EmitResponse"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames = FieldNameMap()


  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
  }

  public func _protoc_generated_isEqualTo(other: Apipb_EmitResponse) -> Bool {
    return true
  }
}

public struct Apipb_WatchRequest: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_WatchRequest"}
  public var protoMessageName: String {return "WatchRequest"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    2: .unique(proto: "profile_id", json: "profileId", swift: "profileId"),
  ]


  ///  profile id is for Create request
  public var profileId: String = ""

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    switch protoFieldNumber {
    case 2: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &profileId)
    default: break
    }
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    if profileId != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: profileId, fieldNumber: 2)
    }
  }

  public func _protoc_generated_isEqualTo(other: Apipb_WatchRequest) -> Bool {
    if profileId != other.profileId {return false}
    return true
  }
}

public struct Apipb_WatchEvent: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_WatchEvent"}
  public var protoMessageName: String {return "WatchEvent"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .same(proto: "type", swift: "type"),
    2: .unique(proto: "profile_id", json: "profileId", swift: "profileId"),
    3: .unique(proto: "child_id", json: "childId", swift: "childId"),
    4: .unique(proto: "game_id", json: "gameId", swift: "gameId"),
  ]


  public enum EventType: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case profileUpdated // = 0
    case childUpdated // = 1
    case childGamesUpdated // = 2
    case childSoundUpdated // = 3
    case UNRECOGNIZED(Int)

    public init() {
      self = .profileUpdated
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .profileUpdated
      case 1: self = .childUpdated
      case 2: self = .childGamesUpdated
      case 3: self = .childSoundUpdated
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public init?(name: String) {
      switch name {
      case "profileUpdated": self = .profileUpdated
      case "childUpdated": self = .childUpdated
      case "childGamesUpdated": self = .childGamesUpdated
      case "childSoundUpdated": self = .childSoundUpdated
      default: return nil
      }
    }

    public init?(jsonName: String) {
      switch jsonName {
      case "PROFILE_UPDATED": self = .profileUpdated
      case "CHILD_UPDATED": self = .childUpdated
      case "CHILD_GAMES_UPDATED": self = .childGamesUpdated
      case "CHILD_SOUND_UPDATED": self = .childSoundUpdated
      default: return nil
      }
    }

    public init?(protoName: String) {
      switch protoName {
      case "PROFILE_UPDATED": self = .profileUpdated
      case "CHILD_UPDATED": self = .childUpdated
      case "CHILD_GAMES_UPDATED": self = .childGamesUpdated
      case "CHILD_SOUND_UPDATED": self = .childSoundUpdated
      default: return nil
      }
    }

    public var rawValue: Int {
      get {
        switch self {
        case .profileUpdated: return 0
        case .childUpdated: return 1
        case .childGamesUpdated: return 2
        case .childSoundUpdated: return 3
        case .UNRECOGNIZED(let i): return i
        }
      }
    }

    public var json: String {
      get {
        switch self {
        case .profileUpdated: return "\"PROFILE_UPDATED\""
        case .childUpdated: return "\"CHILD_UPDATED\""
        case .childGamesUpdated: return "\"CHILD_GAMES_UPDATED\""
        case .childSoundUpdated: return "\"CHILD_SOUND_UPDATED\""
        case .UNRECOGNIZED(let i): return String(i)
        }
      }
    }

    public var hashValue: Int { return rawValue }

    public var debugDescription: String {
      get {
        switch self {
        case .profileUpdated: return ".profileUpdated"
        case .childUpdated: return ".childUpdated"
        case .childGamesUpdated: return ".childGamesUpdated"
        case .childSoundUpdated: return ".childSoundUpdated"
        case .UNRECOGNIZED(let v): return ".UNRECOGNIZED(\(v))"
        }
      }
    }

  }

  public var type: Apipb_WatchEvent.EventType = Apipb_WatchEvent.EventType.profileUpdated

  public var profileId: String = ""

  public var childId: String = ""

  public var gameId: String = ""

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    switch protoFieldNumber {
    case 1: try setter.decodeSingularField(fieldType: Apipb_WatchEvent.EventType.self, value: &type)
    case 2: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &profileId)
    case 3: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &childId)
    case 4: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: &gameId)
    default: break
    }
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    if type != Apipb_WatchEvent.EventType.profileUpdated {
      try visitor.visitSingularField(fieldType: Apipb_WatchEvent.EventType.self, value: type, fieldNumber: 1)
    }
    if profileId != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: profileId, fieldNumber: 2)
    }
    if childId != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: childId, fieldNumber: 3)
    }
    if gameId != "" {
      try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufString.self, value: gameId, fieldNumber: 4)
    }
  }

  public func _protoc_generated_isEqualTo(other: Apipb_WatchEvent) -> Bool {
    if type != other.type {return false}
    if profileId != other.profileId {return false}
    if childId != other.childId {return false}
    if gameId != other.gameId {return false}
    return true
  }
}

public struct Apipb_WatchResponse: SwiftProtobuf.Message, SwiftProtobuf.Proto3Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  public var swiftClassName: String {return "Apipb_WatchResponse"}
  public var protoMessageName: String {return "WatchResponse"}
  public var protoPackageName: String {return "apipb"}
  public static let _protobuf_fieldNames: FieldNameMap = [
    1: .same(proto: "created", swift: "created"),
    2: .same(proto: "canceled", swift: "canceled"),
    3: .same(proto: "event", swift: "event"),
  ]

  private class _StorageClass {
    typealias ExtendedMessage = Apipb_WatchResponse
    var _created: Bool = false
    var _canceled: Bool = false
    var _event: Apipb_WatchEvent? = nil

    init() {}

    func decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
      switch protoFieldNumber {
      case 1: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: &_created)
      case 2: try setter.decodeSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: &_canceled)
      case 3: try setter.decodeSingularMessageField(fieldType: Apipb_WatchEvent.self, value: &_event)
      default: break
      }
    }

    func traverse(visitor: SwiftProtobuf.Visitor) throws {
      if _created != false {
        try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: _created, fieldNumber: 1)
      }
      if _canceled != false {
        try visitor.visitSingularField(fieldType: SwiftProtobuf.ProtobufBool.self, value: _canceled, fieldNumber: 2)
      }
      if let v = _event {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
    }

    func isEqualTo(other: _StorageClass) -> Bool {
      if _created != other._created {return false}
      if _canceled != other._canceled {return false}
      if _event != other._event {return false}
      return true
    }

    func copy() -> _StorageClass {
      let clone = _StorageClass()
      clone._created = _created
      clone._canceled = _canceled
      clone._event = _event
      return clone
    }
  }

  private var _storage = _StorageClass()


  public var created: Bool {
    get {return _storage._created}
    set {_uniqueStorage()._created = newValue}
  }

  public var canceled: Bool {
    get {return _storage._canceled}
    set {_uniqueStorage()._canceled = newValue}
  }

  public var event: Apipb_WatchEvent {
    get {return _storage._event ?? Apipb_WatchEvent()}
    set {_uniqueStorage()._event = newValue}
  }
  public var hasEvent: Bool {
    return _storage._event != nil
  }
  public mutating func clearEvent() {
    return _storage._event = nil
  }

  public init() {}

  public mutating func _protoc_generated_decodeField<T: SwiftProtobuf.FieldDecoder>(setter: inout T, protoFieldNumber: Int) throws {
    try _uniqueStorage().decodeField(setter: &setter, protoFieldNumber: protoFieldNumber)
  }

  public func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    try _storage.traverse(visitor: visitor)
  }

  public func _protoc_generated_isEqualTo(other: Apipb_WatchResponse) -> Bool {
    return _storage === other._storage || _storage.isEqualTo(other: other._storage)
  }

  private mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _storage.copy()
    }
    return _storage
  }
}

//
//  JWTDecoder.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/1/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

/// JWTDecoder for decoding JSON Web Tokens (JWT) tokens
/// Inspired by https://github.com/auth0/jwt-decode.
public struct JWTDecoder {
  private var header: [String: Any] = [:]
  private var payload: [String: Any] = [:]
  private let token: String
  
  public init(token: String) throws {
    self.token = token
    try decode()
  }
}

public extension JWTDecoder {
  var algorithm: String? {
    header["alg"] as? String
  }
  
  var issuer: String? {
    payload["iss"] as? String
  }
  
  var subject: String? {
    payload["sub"] as? String
  }
  
  var identifier: String? {
    payload["jti"] as? String
  }
  
  var issuedAt: Date? {
    dateFor(key: "iat")
  }
  
  var expiresAt: Date? {
    dateFor(key: "exp")
  }
  
  var notBefore: Date? {
    dateFor(key: "nbf")
  }
  
  var isExpired: Bool {
    expiresAt.map { $0.compare(.init()) != .orderedDescending } ?? false
  }
  
  func bool(for key: String) -> Bool? {
    guard let boolValue = payload[key] as? Bool else {
      guard let stringValue = payload[key] as? String else { return nil }
      return Bool(stringValue)
    }
    return boolValue
  }
}

// MARK: - Private Methods
private extension JWTDecoder {
  mutating func decode() throws {
    let components = token.components(separatedBy: ".")
    guard components.count == 3 else { throw Error.invalidStructure }
    
    self.header = try decode(component: components[0])
    self.payload = try decode(component: components[1])
  }
  
  func decode(component: String) throws -> [String: Any] {
    let data = try decode(base64: component)
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
          let payload = json as? [String: Any] else {
      throw Error.invalidJson
    }
    
    return payload
  }
  
  func decode(base64: String) throws -> Data {
    var decoded = base64
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    
    let length = Double(decoded.lengthOfBytes(using: .utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
      let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
      decoded += padding
    }
    
    guard let data = Data(base64Encoded: decoded, options: .ignoreUnknownCharacters) else {
      throw Error.invalidBase64
    }
    return data
  }
  
  func dateFor(key: String) -> Date? {
    if let stringValue = payload[key] as? String, let doubleValue = TimeInterval(stringValue) {
      return Date(timeIntervalSince1970: doubleValue)
    } else if let doubleValue = payload[key] as? Double {
      return Date(timeIntervalSince1970: doubleValue)
    }
    return nil
  }
  
  enum Error: Swift.Error {
    case invalidBase64
    case invalidJson
    case invalidStructure
  }
}

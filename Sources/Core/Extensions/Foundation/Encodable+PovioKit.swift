//
//  Encodable+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public extension Encodable {
  /// Encodes given encodable object into json/dictionary.
  /// ```
  /// struct Request: Encodable {}
  ///
  /// do {
  ///   let encoder = JSONEncoder()
  ///   let requestParameters = try request.toJSON(with: encoder)
  /// } catch {
  ///   // error
  /// }
  /// ```
  func toJSON(with encoder: JSONEncoder) throws -> [String: Any] {
    let data = try encoder.encode(self)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    return (json as? [String: Any]) ?? [:]
  }
}

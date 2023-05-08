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
    guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
      throw JSONError.serialization
    }
    return jsonObject
  }
}

private enum JSONError: Error {
  case serialization
}

//
//  Encodable+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension Encodable {
  /// Encodes given encodable object into json/dictionary.
  /// ```
  /// struct Request: Encodable {}
  ///
  /// do {
  ///   let encoder = JSONEncoder()
  ///   let requestParameters = try request.encode(with: encoder)
  /// } catch {
  ///   // error
  /// }
  /// ```
  func encode(with encoder: JSONEncoder) throws -> [String: Any] {
    do {
      let data = try encoder.encode(self)
      guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        throw JSONError.serialization
      }
      return jsonObject
    } catch let encodingError as EncodingError {
      switch encodingError {
      case .invalidValue(_, let context):
        Logger.debug("Encoding (failure): \(type(of: self))", params: ["error": context.debugDescription])
      @unknown default:
        Logger.debug("Encoding (failure): \(type(of: self))", params: ["error": "Unknown encoding error."])
      }
      throw encodingError
    } catch {
      Logger.debug("Encoding (failure): \(type(of: self))", params: ["error": error.self])
      throw error
    }
  }
}

private enum JSONError: Error {
  case serialization
}

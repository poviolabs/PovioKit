//
//  Data+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 21/08/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public extension Data {
  /// Returns hexadecimal string representation of data object
  /// Usefull for e.g. printing out push notifications `deviceToken`
  var hexadecialString: String {
    map { String(format: "%02x", $0) }.joined()
  }
  
  /// Decodes data to given `type` using given `decoder`.
  /// ```
  /// let decodedUser = responseData.decode(UserResponse.self, with: JSONDecoder())
  /// ```
  func decode<D: Decodable>(_ type: D.Type, with decoder: JSONDecoder) throws -> D {
    do {
      return try decoder.decode(type, from: self)
    } catch let decodingError as DecodingError {
      switch decodingError {
      case .typeMismatch(_, let context),
           .valueNotFound(_, let context),
           .keyNotFound(_, let context),
           .dataCorrupted(let context):
        Logger.debug("Decoding (failure): \(type.self)", params: ["error": context.debugDescription])
      @unknown default:
        Logger.debug("Decoding (failure): \(type.self)", params: ["error": "Unknown decoding error."])
      }
      throw decodingError
    } catch {
      Logger.debug("Decoding (failure): \(type.self)", params: ["error": error.localizedDescription])
      throw error
    }
  }
}

//
//  Data+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 21/08/2020.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public extension Data {
  /// Returns hexadecimal string representation of data object
  /// Usefull for e.g. printing out push notifications `deviceToken`
  var hexadecialString: String {
    map { String(format: "%02x", $0) }.joined()
  }
  
  /// Returns a UTF-8 encoded string.
  var utf8: String? {
    String(data: self, encoding: .utf8)
  }
  
  /// Returns a UTF-16 encoded string.
  var utf16: String? {
    String(data: self, encoding: .utf16)
  }
  
  /// Decodes data to given `type` using given `decoder`.
  ///
  /// # Example
  /// ```swift
  /// let decodedUser = try responseData.decode(UserResponse.self, with: JSONDecoder())
  /// let decodedUser = try JSONDecoder().decode(UserResponse.self, from: responseData)
  /// ```
  func decode<D: Decodable>(_ type: D.Type, with decoder: JSONDecoder) throws -> D {
    try decoder.decode(type, from: self)
  }
}

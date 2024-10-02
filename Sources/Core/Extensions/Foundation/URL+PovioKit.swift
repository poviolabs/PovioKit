//
//  URL+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public extension URL {
  init?(string: String?) {
    guard let string = string else { return nil }
    self.init(string: string)
  }
  
  /// Append parameter to the URL.
  ///
  /// ## Example
  /// ```
  /// let someURL: URL = "https://povio.com"
  /// let newURL = someURL
  ///   .appending("accept", value: "developers")
  ///   .appending("tech", value: "iOS"
  ///
  /// print(newURL) // https://povio.com?accept=developers&tech=iOS
  /// ```
  func appending(_ name: String, value: String?) -> URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return absoluteURL }
    var queryItems = components.queryItems ?? []
    let newQueryItem = URLQueryItem(name: name, value: value)
    queryItems.append(newQueryItem)
    components.queryItems = queryItems
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    return components.url ?? absoluteURL
  }
  
  /// Retrieves the query parameters from the URL as a dictionary.
  ///
  /// - Returns: An optional dictionary where the keys are `AnyHashable` representing the query parameter names,
  ///            and the values are `Any` representing the corresponding query parameter values.
  ///            Returns nil if the URL is invalid or has no query parameters.
  var queryParameters: [AnyHashable: Any]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
          let queryItems = components.queryItems else { return nil }
    var params: [AnyHashable: Any] = [:]
    queryItems.forEach { queryItem in
      queryItem.value.map { params[queryItem.name] = $0 }
    }
    return params
  }
}

extension URL: @retroactive ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    guard let url = URL(string: value) else {
      fatalError("Invalid URL string!")
    }
    self = url
  }
}

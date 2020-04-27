//
//  URL+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public extension URL {
  init?(string: String?) {
    guard let string = string else { return nil }
    self.init(string: string)
  }
  
  /// Append parameter to the URL
  func appending(_ name: String, value: String?) -> URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return absoluteURL }
    var queryItems = components.queryItems ?? []
    let newQueryItem = URLQueryItem(name: name, value: value)
    queryItems.append(newQueryItem)
    components.queryItems = queryItems
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    return components.url ?? absoluteURL
  }
}

extension URL: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    guard let url = URL(string: value) else {
      fatalError("Invalid URL string.")
    }
    self = url
  }
}

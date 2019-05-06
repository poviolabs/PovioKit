//
//  URL+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public extension URL {
  init?(string: String?) {
    guard let string = string else { return nil }
    self.init(string: string)
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

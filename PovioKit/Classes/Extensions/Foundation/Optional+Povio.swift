//
//  Optional+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    switch self {
    case let collection?:
      return collection.isEmpty
    case nil:
      return true
    }
  }
}

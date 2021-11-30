//
//  Optional+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2021 Povio Inc. All rights reserved.
//

import Foundation

public extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
}

public extension Optional where Wrapped == String {
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
}

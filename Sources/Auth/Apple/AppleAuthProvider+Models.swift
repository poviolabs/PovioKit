//
//  AppleAuthProvider+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 28/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension AppleAuthProvider {
  enum Nonce {
    case random(length: UInt)
  }
}

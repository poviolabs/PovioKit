//
//  AppleAuthProvider+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 28/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension AppleAuthProvider {
  struct Response {
    let token: String
    var name: String?
    var email: String?
  }
  
  enum Error: Swift.Error {
    case system(_ error: Swift.Error)
    case invalidNonceLength
    case invalidIdentityToken
    case unhandledAuthorization
  }
  
  enum Nonce {
    case random(length: UInt)
  }
}

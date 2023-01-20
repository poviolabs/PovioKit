//
//  AppleAuthenticator+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 28/10/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import AuthenticationServices
import Foundation

public extension AppleAuthenticator {
  enum Nonce {
    case random(length: UInt)
  }
}

extension ASAuthorizationAppleIDCredential {
  var displayName: String {
    [fullName?.givenName, fullName?.familyName]
      .compactMap { $0 }
      .joined(separator: " ")
  }
}

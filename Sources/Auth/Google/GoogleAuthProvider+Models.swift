//
//  GoogleAuthProvider+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 26/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import GoogleSignIn

public extension GoogleAuthProvider {
  struct Config {
    let clientId: String
    
    public init(clientId: String) {
      self.clientId = clientId
    }
  }
}

public extension GIDProfileData {
  var displayName: String {
    [givenName, familyName]
      .compactMap { $0 }
      .joined(separator: " ")
  }
}

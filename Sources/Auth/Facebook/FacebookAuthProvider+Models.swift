//
//  GoogleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 30/11/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import FacebookLogin

public extension FacebookAuthProvider {
  struct Config {
    let permissions: [Permission] = [.email, .publicProfile]
    /// By default, we request `email` and `publicProfile` permission.
    /// If you want to request more permissions, define it here.
    let extraPermissions: [Permission]
    
    public init(extraPermissions: [Permission] = []) {
      self.extraPermissions = extraPermissions
    }
  }
  
  struct GraphResponse: Decodable {
    let email: String?
    let firstName: String?
    let lastName: String?
  }
}

public extension FacebookAuthProvider.GraphResponse {
  var displayName: String {
    [firstName, lastName]
      .compactMap { $0 }
      .joined(separator: " ")
  }
}

//
//  GoogleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 30/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import FacebookLogin

public extension FacebookAuthProvider {
  struct Config {
    /// By default, we request `email` and `publicProfile` permission.
    /// If you want to request more permissions, define it here.
    let extraPermissions: [Permission]
  }
  
  struct GraphResponse: Decodable {
    let email: String?
    let firstName: String?
    let lastName: String?
  }
}

public extension FacebookAuthProvider.GraphResponse {
  var fullName: String? {
    [firstName, lastName]
      .compactMap { $0 }
      .joined(separator: " ")
  }
}
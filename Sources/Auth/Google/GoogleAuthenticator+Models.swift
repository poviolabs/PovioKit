//
//  GoogleAuthenticator+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 30/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public extension GoogleAuthenticator {
  struct Response {
    public let token: String
    public let name: String?
    public let email: String?
  }
}

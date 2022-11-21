//
//  GoogleAuthProvider+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 26/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension GoogleAuthProvider {
  struct Config {
    let clientId: String
  }
  
  struct Response {
    let token: String
    var name: String?
    var email: String?
  }
  
  enum Error: Swift.Error {
    case system(_ error: Swift.Error)
    case missingPresentingViewController
    case undefined
  }
}

//
//  AuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public protocol AuthProvidable {
  func signIn()
  static func signOut()
  static func checkAuthState(_ state: @escaping (Bool) -> Swift.Void)
}

public struct AuthProvider {
  public struct Response {
    let token: String
    var name: String?
    var email: String?
    
    public init(token: String, name: String? = nil, email: String? = nil) {
      self.token = token
      self.name = name
      self.email = email
    }
  }
  
  public enum Error: Swift.Error {
    case system(_ error: Swift.Error)
    case cancelled
    case invalidNonceLength
    case invalidIdentityToken
    case unhandledAuthorization
    case missingPresentingViewController
  }
}

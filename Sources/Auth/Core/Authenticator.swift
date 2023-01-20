//
//  Authenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/11/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public struct Authenticator {
  public struct Response {
    public let token: String
    public let name: String?
    public let email: Email?
    
    public init(token: String, name: String? = nil, email: Email? = nil) {
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
    case alreadySignedIn
    case credentialsRevoked
  }
}

public extension Authenticator.Response {
  struct Email {
    public let address: String
    public let isPrivate: Bool?
    public let isVerified: Bool?
    
    public init(_ address: String, isPrivate: Bool? = nil, isVerified: Bool? = nil) {
      self.address = address
      self.isPrivate = isPrivate
      self.isVerified = isVerified
    }
  }
}

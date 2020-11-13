//
//  SignInWithApple+Models.swift
//  Skip
//
//  Created by Borut Tomažin on 21/11/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
extension SignInWithApple {
  enum Error: Swift.Error {
    case missingNonce
    case missingIdentityToken
    case invalidIdentityToken
    case unhandledAuthorization
  }
  
  enum Nonce {
    case random(length: Int)
  }
}

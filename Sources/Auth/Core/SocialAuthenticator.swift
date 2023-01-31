//
//  SocialAuthenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 30/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import PovioKitPromise
import Foundation
import UIKit

public class SocialAuthenticator {
  private let authenticators: [Authenticator]
  
  public init(authenticators: [Authenticator]) {
    self.authenticators = authenticators
  }
}

extension SocialAuthenticator {
  public func authenticator<A: Authenticator>(for type: A.Type) -> A? {
    authenticators.first { $0 is A } as? A
  }
  
  public func signOut() {
    _ = all(promises: authenticators.map { $0.isAuthenticated.and($0) })
      .map { $0.forEach { if $0.0 { $0.1.signOut() } }}
  }
  
  public var isAuthenticated: PovioKitPromise.Promise<Authenticator.Authenticated> {
    all(promises: authenticators.map { $0.isAuthenticated })
      .map { $0.contains(true) }
  }
}

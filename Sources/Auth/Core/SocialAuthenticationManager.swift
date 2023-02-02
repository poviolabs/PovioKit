//
//  SocialAuthenticationManager.swift
//  PovioKit
//
//  Created by Borut Tomazin on 30/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import PovioKitPromise
import Foundation
import UIKit

public class SocialAuthenticationManager {
  private let authenticators: [Authenticator]
  
  public init(authenticators: [Authenticator]) {
    self.authenticators = authenticators
  }
}

extension SocialAuthenticationManager: Authenticator {
  public var isAuthenticated: Authenticator.Authenticated {
    authenticators.map { $0.isAuthenticated }.contains(true)
  }
  
  public var currentAuthenticator: Authenticator? {
    authenticators.first { $0.isAuthenticated }
  }
  
  public func authenticator<A: Authenticator>(for type: A.Type) -> A? {
    authenticators.first { $0 is A } as? A
  }
  
  public func signOut() {
    authenticators.forEach { $0.signOut() }
  }
  
  public func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    currentAuthenticator?.canOpenUrl(url, application: application, options: options) ?? false
  }
}

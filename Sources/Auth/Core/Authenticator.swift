//
//  Authenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import PovioKitPromise
import UIKit

public protocol Authenticator {
  typealias Authenticated = Bool
  
  func signOut()
  var isAuthenticated: Promise<Authenticated> { get }
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

public class Manager {
  
  private let providers: [Authenticator]
  public init(providers: [Authenticator]) {
    self.providers = providers
  }
  
  public func getAuth<A: Authenticator>(type: A.Type) -> A? {
//    AppleAuthenticator().signIn()?
    providers.first { $0 is A } as? A
  }
  
  public func logout() {
    all(promises: providers.map { $0.isAuthenticated })
      .map { $0.enumerated().forEach {
        if $1 {
        }
      } }
  }
  
//  static func shouldHandleURL(_ url: URL) -> Bool
}

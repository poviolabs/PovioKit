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
  
  var isAuthenticated: Promise<Authenticated> { get }
  
  func signOut()
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

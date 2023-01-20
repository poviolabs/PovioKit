//
//  AuthProvidable.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/01/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import PovioKitPromise
import UIKit

public protocol AuthProvidable {
  typealias Authenticated = Bool
  typealias Response = Authenticator.Response
  
  func signIn(from presentingViewController: UIViewController) -> Promise<Response>
  func signOut()
}

//
//  GoogleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import GoogleSignIn

public protocol GoogleAuthProviderDelegate: AnyObject {
  func googleAuthProviderDidSignIn(with response: GoogleAuthProvider.Response)
  func googleAuthProviderDidFail(with error: GoogleAuthProvider.Error)
}

public final class GoogleAuthProvider: NSObject {
  private let config: Config
  private weak var delegate: GoogleAuthProviderDelegate?
  private weak var presentingViewController: UIViewController?
  private let authProvider: GIDSignIn
  
  /// Class initializer with `config`, `presentingViewController` and optional `delegate`.
  init(with config: Config, on presentingViewController: UIViewController, delegate: GoogleAuthProviderDelegate?) {
    self.config = config
    self.presentingViewController = presentingViewController
    self.delegate = delegate
    self.authProvider = GIDSignIn.sharedInstance
    super.init()
  }
}

// MARK: - Public Methods
public extension GoogleAuthProvider {
  /// SignIn user.
  ///
  /// Will notify the delegate with the `Response` object on success or with `Error` on error.
  func signIn() {
    guard !authProvider.hasPreviousSignIn() else {
      authProvider.restorePreviousSignIn()
      return
    }
    
    guard let presentingVC = presentingViewController else {
      delegate?.googleAuthProviderDidFail(with: .missingPresentingViewController)
      return
    }
    
    authProvider
      .signIn(with: .init(clientID: config.clientId),
              presenting: presentingVC) { [weak self] user, error in
        switch (user, error) {
        case (let signedInUser?, _):
          signedInUser.authentication.do { [weak self] auth, error in
            switch (auth, error) {
            case (.some(let auth), _):
              let userProfile = signedInUser.profile
              let fullName = [userProfile?.givenName, userProfile?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
              let response = Response(token: auth.accessToken,
                                      name: fullName,
                                      email: userProfile?.email)
              self?.delegate?.googleAuthProviderDidSignIn(with: response)
            case (_, .some(let error)):
              self?.delegate?.googleAuthProviderDidFail(with: .system(error))
            default:
              return
            }
          }
        case (_, let actualError?):
          let errorCode = (actualError as NSError).code
          guard errorCode != GIDSignInError.Code.canceled.rawValue else { return }
          self?.delegate?.googleAuthProviderDidFail(with: .system(actualError))
        case (.none, .none):
          self?.delegate?.googleAuthProviderDidFail(with: .undefined)
        }
      }
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  func signOut() {
    authProvider.signOut()
  }
  
  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  func shouldHandleURL(_ url: URL) -> Bool {
    authProvider.handle(url)
  }
}

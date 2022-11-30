//
//  GoogleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import GoogleSignIn
import PovioKitAuthCore

public protocol GoogleAuthProvidable: AuthProvidable {
  static func shouldHandleURL(_ url: URL) -> Bool
}

public protocol GoogleAuthProviderDelegate: AnyObject {
  func googleAuthProviderDidSignIn(with response: AuthProvider.Response)
  func googleAuthProviderDidFail(with error: AuthProvider.Error)
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
extension GoogleAuthProvider: GoogleAuthProvidable {
  /// SignIn user.
  ///
  /// Will notify the delegate with the `Response` object on success or with `Error` on error.
  public func signIn() {
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
              let response = AuthProvider.Response(token: auth.accessToken,
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
          self?.delegate?.googleAuthProviderDidFail(with: .unhandledAuthorization)
        }
      }
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public static func signOut() {
    GIDSignIn.sharedInstance.signOut()
  }
  
  /// Checks the current auth state and returns the boolean value.
  public static func checkAuthState(_ state: @escaping (Bool) -> Swift.Void) {
    state(GIDSignIn.sharedInstance.currentUser != nil)
  }
  
  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  public static func shouldHandleURL(_ url: URL) -> Bool {
    GIDSignIn.sharedInstance.handle(url)
  }
}

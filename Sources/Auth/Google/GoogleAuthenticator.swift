//
//  GoogleAuthenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/10/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import GoogleSignIn
import PovioKitAuthCore
import PovioKitPromise

public protocol GoogleAuthProvidable: AuthProvidable {
//  typealias Authenticated = Bool
//  typealias Response = AuthProvider.Response
  var isAuthenticated: Authenticated { get }
  static func shouldHandleURL(_ url: URL) -> Bool
}

public final class GoogleAuthenticator {
  private let config: Config
  private let provider: GIDSignIn
  
  public init(with config: Config) {
    self.config = config
    self.provider = GIDSignIn.sharedInstance
  }
}

// MARK: - Public Methods
extension GoogleAuthenticator: GoogleAuthProvidable {
  /// SignIn user.
  ///
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(from presentingViewController: UIViewController) -> Promise<Response> {
    guard !provider.hasPreviousSignIn() else {
      provider.restorePreviousSignIn()
      return .error(Authenticator.Error.alreadySignedIn)
    }
    
    return Promise { seal in
      provider
        .signIn(with: .init(clientID: config.clientId),
                presenting: presentingViewController) { user, error in
          switch (user, error) {
          case (let signedInUser?, _):
            signedInUser.authentication.do { auth, error in
              switch (auth, error) {
              case (.some(let auth), _):
                let userProfile = signedInUser.profile
                let email = userProfile.map { Authenticator.Response.Email($0.email) }
                let response = Response(token: auth.accessToken,
                                        name: userProfile?.displayName,
                                        email: email)
                seal.resolve(with: response)
              case (_, .some(let error)):
                seal.reject(with: Authenticator.Error.system(error))
              default:
                seal.reject(with: Authenticator.Error.unhandledAuthorization)
              }
            }
          case (_, let actualError?):
            let errorCode = (actualError as NSError).code
            if errorCode == GIDSignInError.Code.canceled.rawValue {
              seal.reject(with: Authenticator.Error.cancelled)
            } else {
              seal.reject(with: Authenticator.Error.system(actualError))
            }
          case (.none, .none):
            seal.reject(with: Authenticator.Error.unhandledAuthorization)
          }
        }
    }
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public func signOut() {
    provider.signOut()
  }
  
  /// Returns the current authentication state.
  public var isAuthenticated: Authenticated {
    provider.currentUser != nil
  }
  
  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  public static func shouldHandleURL(_ url: URL) -> Bool {
    GIDSignIn.sharedInstance.handle(url)
  }
}

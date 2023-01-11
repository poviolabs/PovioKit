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

public protocol GoogleAuthProvidable {
  typealias Authorized = Bool
  typealias Response = AuthProvider.Response
  
  func signIn(from presentingViewController: UIViewController) -> Promise<Response>
  static func signOut()
  static func isAuthorized() -> Authorized
  static func shouldHandleURL(_ url: URL) -> Bool
}

public final class GoogleAuthenticator {
  private let config: Config
  private let authProvider: GIDSignIn
  
  public init(with config: Config) {
    self.config = config
    self.authProvider = GIDSignIn.sharedInstance
  }
}

// MARK: - Public Methods
extension GoogleAuthenticator: GoogleAuthProvidable {
  /// SignIn user.
  ///
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(from presentingViewController: UIViewController) -> Promise<Response> {
    guard !authProvider.hasPreviousSignIn() else {
      authProvider.restorePreviousSignIn()
      return .error(AuthProvider.Error.alreadySignedIn)
    }
    
    return Promise { seal in
      authProvider
        .signIn(with: .init(clientID: config.clientId),
                presenting: presentingViewController) { user, error in
          switch (user, error) {
          case (let signedInUser?, _):
            signedInUser.authentication.do { auth, error in
              switch (auth, error) {
              case (.some(let auth), _):
                let userProfile = signedInUser.profile
                let email = userProfile.map { AuthProvider.Response.Email($0.email) }
                let response = Response(token: auth.accessToken,
                                        name: userProfile?.displayName,
                                        email: email)
                seal.resolve(with: response)
              case (_, .some(let error)):
                seal.reject(with: AuthProvider.Error.system(error))
              default:
                seal.reject(with: AuthProvider.Error.unhandledAuthorization)
              }
            }
          case (_, let actualError?):
            let errorCode = (actualError as NSError).code
            if errorCode == GIDSignInError.Code.canceled.rawValue {
              seal.reject(with: AuthProvider.Error.cancelled)
            } else {
              seal.reject(with: AuthProvider.Error.system(actualError))
            }
          case (.none, .none):
            seal.reject(with: AuthProvider.Error.unhandledAuthorization)
          }
        }
    }
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public static func signOut() {
    GIDSignIn.sharedInstance.signOut()
  }
  
  /// Checks the current auth state and returns the boolean value.
  public static func isAuthorized() -> Authorized {
    GIDSignIn.sharedInstance.currentUser != nil
  }
  
  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  public static func shouldHandleURL(_ url: URL) -> Bool {
    GIDSignIn.sharedInstance.handle(url)
  }
}

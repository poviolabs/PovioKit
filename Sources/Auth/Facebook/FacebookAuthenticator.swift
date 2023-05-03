//
//  FacebookAuthenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 29/11/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import FacebookLogin
import PovioKitCore
import PovioKitAuthCore
import PovioKitPromise

public final class FacebookAuthenticator {
  private let provider: LoginManager
  
  public init() {
    self.provider = .init()
  }
}

// MARK: - Public Methods
extension FacebookAuthenticator: Authenticator {
  /// SignIn user.
  ///
  /// The `permissions` to use when doing a sign in.
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(
    from presentingViewController: UIViewController,
    with permissions: [Permission] = [.email, .publicProfile]) -> Promise<Response>
  {
    let permissions: [String] = permissions.map { $0.name }
    
    return signIn(with: permissions, on: presentingViewController)
      .flatMap(with: fetchUserDetails)
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public func signOut() {
    provider.logOut()
  }
  
  /// Returns the current authentication state.
  public var isAuthenticated: Authenticated {
    guard let token = AccessToken.current else { return false }
    return !token.isExpired
  }
  
  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  public func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    ApplicationDelegate.shared.application(application, open: url, options: options)
  }
}

// MARK: - Error
public extension FacebookAuthenticator {
  enum Error: Swift.Error {
    case system(_ error: Swift.Error)
    case cancelled
    case invalidIdentityToken
    case invalidUserData
    case missingUserData
    case userDataDecode
  }
}

// MARK: - Private Methods
private extension FacebookAuthenticator {
  func signIn(with permissions: [String], on presentingViewController: UIViewController) -> Promise<AccessToken> {
    Promise { seal in
      provider
        .logIn(permissions: permissions, from: presentingViewController) { result, error in
          switch (result, error) {
          case (let result?, nil):
            if result.isCancelled {
              seal.reject(with: Error.cancelled)
            } else if let token = result.token {
              seal.resolve(with: token)
            } else {
              seal.reject(with: Error.invalidIdentityToken)
            }
          case (nil, let error?):
            seal.reject(with: Error.system(error))
          case _:
            seal.reject(with: Error.system(NSError(domain: "com.povio.facebook.error", code: -1, userInfo: nil)))
          }
        }
    }
  }
  
  func fetchUserDetails(with token: AccessToken) -> Promise<Response> {
    let request = GraphRequest(
      graphPath: "me",
      parameters: ["fields": "id, email, first_name, last_name"],
      tokenString: token.tokenString,
      httpMethod: nil,
      flags: .doNotInvalidateTokenOnError
    )
    
    return Promise { seal in
      request.start { _, result, error in
        switch result {
        case .some(let response):
          guard let dict = response as? [String: String] else {
            Logger.error("Response is invalid!")
            seal.reject(with: Error.invalidUserData)
            return
          }
          
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          
          let encoder = JSONEncoder()
          encoder.keyEncodingStrategy = .convertToSnakeCase
          
          do {
            let data = try encoder.encode(dict)
            let object = try data.decode(GraphResponse.self, with: decoder)
            
            let authResponse = Response(
              userId: object.id,
              token: token.tokenString,
              name: object.displayName,
              email: object.email,
              expiresAt: token.expirationDate
            )
            seal.resolve(with: authResponse)
          } catch {
            Logger.error("Failed to decode user details!")
            seal.reject(with: Error.userDataDecode)
          }
        case .none:
          Logger.error("Failed to fetch user details!")
          seal.reject(with: Error.missingUserData)
        }
      }
    }
  }
}

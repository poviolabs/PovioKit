//
//  FacebookAuthenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 29/11/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import FacebookLogin
import PovioKit
import PovioKitAuthCore
import PovioKitPromise

public final class FacebookAuthenticator {
  public typealias Token = String
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
    let configuration = LoginConfiguration(permissions: permissions, tracking: .limited)
    
    return signIn(with: configuration, on: presentingViewController)
      .flatMap(with: fetchUserDetails)
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public func signOut() {
    provider.logOut()
  }
  
  /// Returns the current authentication state.
  public var isAuthenticated: Promise<Authenticated> {
    guard let token = AccessToken.current else { return .value(false) }
    return .value(!token.isExpired)
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
  }
}

// MARK: - Private Methods
private extension FacebookAuthenticator {
  func signIn(with configuration: LoginConfiguration?, on presentingViewController: UIViewController) -> Promise<Token> {
    Promise { seal in
      provider
        .logIn(viewController: presentingViewController,
               configuration: configuration) {
          switch $0 {
          case let .success(_, _, accessToken):
            switch accessToken {
            case .some(let token):
              seal.resolve(with: token.tokenString)
            case .none:
              seal.reject(with: Error.invalidIdentityToken)
            }
          case .cancelled:
            seal.reject(with: Error.cancelled)
          case .failed(let error):
            seal.reject(with: Error.system(error))
          }
        }
    }
  }
  
  func fetchUserDetails(withToken token: String) -> Promise<Response> {
    let request = GraphRequest(
      graphPath: "me",
      parameters: ["fields": "email, first_name, last_name"],
      tokenString: token,
      httpMethod: nil,
      flags: .doNotInvalidateTokenOnError
    )
    
    return Promise { seal in
      request.start { _, result, error in
        var graphResponse: GraphResponse?
        
        switch result {
        case .some(let response):
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          if let data = (response as? Data),
             let object = try? data.decode(GraphResponse.self, with: decoder) {
            graphResponse = object
          }
        case .none:
          break
        }
        
        if graphResponse == nil {
          Logger.error("Failed to fetch user details!")
        }
        
        let authResponse = Response(
          token: token,
          name: graphResponse?.displayName,
          email: graphResponse?.email
        )
        seal.resolve(with: authResponse)
      }
    }
  }
}

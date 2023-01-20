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

public protocol FacebookAuthProvidable: AuthProvidable {
  func signIn(from presentingViewController: UIViewController,
              with extraPermissions: [Permission]) -> Promise<Response>
  var isAuthenticated: Authenticated { get }
}

public final class FacebookAuthenticator {
  public typealias Token = String
  private let provider: LoginManager
  private let defaultPermissions: [Permission] = [.email, .publicProfile]
  
  public init() {
    self.provider = .init()
  }
}

// MARK: - Public Methods
extension FacebookAuthenticator: FacebookAuthProvidable {
  /// SignIn user.
  ///
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(from presentingViewController: UIViewController) -> Promise<Response> {
    let permissions: [String] = defaultPermissions.map { $0.name }
    let configuration = LoginConfiguration(permissions: permissions, tracking: .limited)
    
    return signIn(with: configuration, on: presentingViewController)
      .flatMap(with: fetchUserDetails)
  }
  
  public func signIn(from presentingViewController: UIViewController, with extraPermissions: [Permission]) -> Promise<Response> {
    let permissions: [String] = (defaultPermissions + extraPermissions).map { $0.name }
    let configuration = LoginConfiguration(permissions: permissions, tracking: .limited)
    
    return signIn(with: configuration, on: presentingViewController)
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
              seal.reject(with: Authenticator.Error.invalidIdentityToken)
            }
          case .cancelled:
            seal.reject(with: Authenticator.Error.cancelled)
          case .failed(let error):
            seal.reject(with: Authenticator.Error.system(error))
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
          email: graphResponse?.email.map { Authenticator.Response.Email($0) }
        )
        seal.resolve(with: authResponse)
      }
    }
  }
}

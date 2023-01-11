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

public protocol FacebookAuthProvidable {
  typealias Authorized = Bool
  typealias Response = AuthProvider.Response
  
  func signIn(from presentingViewController: UIViewController) -> Promise<Response>
  static func signOut()
  static func isAuthorized() -> Authorized
}

public final class FacebookAuthenticator {
  public typealias Token = String
  private let config: Config
  private let authProvider: LoginManager
  private let defaultPermissions: [Permission] = [.email, .publicProfile]
  
  public init(with config: Config? = nil) {
    self.config = config ?? .init()
    self.authProvider = .init()
  }
}

// MARK: - Public Methods
extension FacebookAuthenticator: FacebookAuthProvidable {
  /// SignIn user.
  ///
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(from presentingViewController: UIViewController) -> Promise<Response> {
    let permissions: [String] = (defaultPermissions + config.extraPermissions).map { $0.name }
    let configuration = LoginConfiguration(permissions: permissions, tracking: .limited)
    
    return signIn(with: configuration, on: presentingViewController)
      .flatMap(with: fetchUserDetails)
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public static func signOut() {
    LoginManager().logOut()
  }
  
  /// Checks the current auth state and returns the boolean value.
  public static func isAuthorized() -> Authorized {
    let exists = AccessToken.current?.tokenString != nil
    let isValid = !(AccessToken.current?.isExpired ?? true)
    return exists && isValid
  }
}

// MARK: - Private Methods
private extension FacebookAuthenticator {
  func signIn(with configuration: LoginConfiguration?, on presentingViewController: UIViewController) -> Promise<Token> {
    Promise { seal in
      authProvider
        .logIn(viewController: presentingViewController,
               configuration: configuration) {
          switch $0 {
          case let .success(_, _, accessToken):
            switch accessToken {
            case .some(let token):
              seal.resolve(with: token.tokenString)
            case .none:
              seal.reject(with: AuthProvider.Error.invalidIdentityToken)
            }
          case .cancelled:
            seal.reject(with: AuthProvider.Error.cancelled)
          case .failed(let error):
            seal.reject(with: AuthProvider.Error.system(error))
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
          email: graphResponse?.email.map { AuthProvider.Response.Email($0) }
        )
        seal.resolve(with: authResponse)
      }
    }
  }
}

//
//  GoogleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 29/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import FacebookLogin
import PovioKit
import PovioKitAuthCore

public protocol FacebookAuthProvidable: AuthProvidable { /* ... */ }

public protocol FacebookAuthProviderDelegate: AnyObject {
  func facebookAuthProviderDidSignIn(with response: AuthProvider.Response)
  func facebookAuthProviderDidFail(with error: AuthProvider.Error)
}

public final class FacebookAuthProvider: NSObject {
  private let config: Config
  private weak var delegate: FacebookAuthProviderDelegate?
  private weak var presentingViewController: UIViewController?
  private let authProvider: LoginManager
  private let defaultPermissions: [Permission] = [.email, .publicProfile]
  
  /// Class initializer with `config`, `presentingViewController` and optional `delegate`.
  init(with config: Config, on presentingViewController: UIViewController, delegate: FacebookAuthProviderDelegate?) {
    self.config = config
    self.presentingViewController = presentingViewController
    self.delegate = delegate
    self.authProvider = LoginManager()
    super.init()
  }
}

// MARK: - Public Methods
extension FacebookAuthProvider: FacebookAuthProvidable {
  /// SignIn user.
  ///
  /// Will notify the delegate with the `Response` object on success or with `Error` on error.
  public func signIn() {
    let permissions: [String] = (defaultPermissions + config.extraPermissions).map { $0.name }
    let configuration = LoginConfiguration(permissions: permissions, tracking: .limited)
    authProvider
      .logIn(viewController: presentingViewController,
             configuration: configuration) { [weak self] result in
        switch result {
        case let .success(_, _, accessToken):
          switch accessToken {
          case .some(let token):
            self?.fetchUserDetails(withToken: token.tokenString)
          case .none:
            self?.delegate?.facebookAuthProviderDidFail(with: .invalidIdentityToken)
          }
        case .cancelled:
          self?.delegate?.facebookAuthProviderDidFail(with: .cancelled)
        case .failed(let error):
          self?.delegate?.facebookAuthProviderDidFail(with: .system(error))
        }
      }
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public static func signOut() {
    LoginManager().logOut()
  }
  
  /// Checks the current auth state and returns the boolean value.
  public static func checkAuthState(_ state: @escaping (Bool) -> Swift.Void) {
    let exists = AccessToken.current?.tokenString != nil
    let isValid = !(AccessToken.current?.isExpired ?? true)
    state(exists && isValid)
  }
}

// MARK: - Private Methods
private extension FacebookAuthProvider {
  func fetchUserDetails(withToken token: String) {
    let request = GraphRequest(
      graphPath: "me",
      parameters: ["fields": "email, first_name, last_name"],
      tokenString: token,
      httpMethod: nil,
      flags: .doNotInvalidateTokenOnError
    )
    
    request.start { _, result, error in
      var graphResponse: GraphResponse?
      switch result {
      case .some(let response):
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = (response as? Data),
              let object = try? data.decode(GraphResponse.self, with: decoder) else { return }
        graphResponse = object
      case .none:
        break
      }
      
      let authResponse = AuthProvider.Response(
        token: token,
        name: graphResponse?.fullName,
        email: graphResponse?.email
      )
      self.delegate?.facebookAuthProviderDidSignIn(with: authResponse)
    }
  }
}

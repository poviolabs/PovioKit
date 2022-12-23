//
//  AppleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import PovioKitAuthCore

public protocol AppleAuthProvidable: AuthProvidable {
  func signIn(on presentingViewController: UIViewController, with nonce: AppleAuthProvider.Nonce)
}

public protocol AppleAuthProviderDelegate: AnyObject {
  func appleAuthProviderDidSignIn(with response: AuthProvider.Response)
  func appleAuthProviderDidFail(with error: AuthProvider.Error)
  func appleAuthProviderCredentialsRevoked()
}

public final class AppleAuthProvider: NSObject {
  public weak var delegate: AppleAuthProviderDelegate?
  private static let userIdStorageKey = "povioKit.appleSocialProvider.signIn.userId"
  private static let storage: UserDefaults = .standard
  private let authProvider: ASAuthorizationAppleIDProvider
  
  /// Class initializer
  public override init() {
    self.authProvider = .init()
    super.init()
    setupCredentialsRevokeListener()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Public Methods
extension AppleAuthProvider: AppleAuthProvidable {
  /// SignIn user
  ///
  /// Will notify the delegate with the `Response` object on success or with `Error` on error.
  public func signIn(on presentingViewController: UIViewController) {
    appleSignIn(on: presentingViewController, with: nil)
  }
  
  /// SignIn user with `nonce` value, which is usually needed when doing auth with an external auth provider (e.g. firebase).
  ///
  /// Will notify the delegate with the `Response` object on success or with `Error` on error.
  public func signIn(on presentingViewController: UIViewController, with nonce: Nonce) {
    appleSignIn(on: presentingViewController, with: nonce)
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public static func signOut() {
    storage.removeObject(forKey: userIdStorageKey)
  }
  
  /// Checks the current auth state and returns the boolean value.
  public static func checkAuthState(_ state: @escaping (Bool) -> Swift.Void) {
    guard let userId = Self.storage.string(forKey: Self.userIdStorageKey) else {
      state(false)
      return
    }
    
    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { credentialsState, _ in
      state(credentialsState == .authorized)
    }
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthProvider: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let credential as ASAuthorizationAppleIDCredential:
      guard let identityToken = credential.identityToken,
            let identityTokenString = String(data: identityToken, encoding: .utf8) else {
        delegate?.appleAuthProviderDidFail(with: .invalidIdentityToken)
        return
      }
      
      // store userId for later
      Self.storage.set(credential.user, forKey: Self.userIdStorageKey)
      
      let displayName = [credential.fullName?.givenName, credential.fullName?.familyName]
        .compactMap { $0 }
        .joined(separator: " ")
      
      delegate?.appleAuthProviderDidSignIn(with: .init(token: identityTokenString,
                                                       name: displayName,
                                                       email: credential.email))
    case _:
      delegate?.appleAuthProviderDidFail(with: .unhandledAuthorization)
    }
  }
  
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Swift.Error) {
    delegate?.appleAuthProviderDidFail(with: .system(error))
  }
}

// MARK: - Private Methods
private extension AppleAuthProvider {
//  var checkedDelegate: AppleAuthProviderDelegate? {
//    if delegate == nil {
//      delegate?.appleAuthProviderDidFail(with: .cancelled)
//    }
//    return delegate
//  }
  
  func appleSignIn(on presentingViewController: UIViewController, with nonce: Nonce?) {
    let request = authProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    switch nonce {
    case .random(let length):
      guard length > 0 else {
        delegate?.appleAuthProviderDidFail(with: .invalidNonceLength)
        return
      }
      request.nonce = generateRandomNonceString(length: length).sha256
    case .none:
      break
    }
    
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = presentingViewController
    controller.performRequests()
  }
  
  func generateRandomNonceString(length: UInt = 32) -> String {
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    let result = (0..<length).compactMap { _ in charset.randomElement() }
    guard result.count == length else { fatalError("Unable to generate nonce!") }
    return String(result)
  }
  
  func setupCredentialsRevokeListener() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(appleCredentialRevoked),
                                           name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
                                           object: nil)
  }
}

// MARK: - Actions
private extension AppleAuthProvider {
  @objc func appleCredentialRevoked() {
    delegate?.appleAuthProviderCredentialsRevoked()
  }
}

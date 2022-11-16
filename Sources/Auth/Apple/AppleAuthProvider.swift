//
//  AppleAuthProvider.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AuthenticationServices
import CryptoKit
import Foundation

public protocol AppleAuthProviderDelegate: AnyObject {
  func appleAuthProviderDidSignIn(with response: AppleAuthProvider.Response)
  func appleAuthProviderDidFail(with error: AppleAuthProvider.Error)
  func appleAuthProviderIsAuthorized(_ authorized: Bool)
}

public final class AppleAuthProvider: NSObject {
  private weak var delegate: AppleAuthProviderDelegate?
  private let presentationAnchor: ASPresentationAnchor?
  private let userIdStorageKey = "povioKit.appleSocialProvider.signIn.userId"
  private let storage: UserDefaults
  private let authProvider: ASAuthorizationAppleIDProvider
  
  /// Class initializer with optional `presentationAnchor` param. You should usually pass the main window.
  /// If you don't pass it, `UIWindow()` is created manually for it.
  public init(with presentationAnchor: ASPresentationAnchor? = nil, delegate: AppleAuthProviderDelegate?) {
    self.presentationAnchor = presentationAnchor
    self.delegate = delegate
    self.storage = .standard
    self.authProvider = .init()
    super.init()
    setupCredentialsRevokeListener()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Public Methods
public extension AppleAuthProvider {
  /// SignIn with optional `nonce` value, which is usually needed when doing auth with an external auth provider (e.g. firebase).
  ///
  /// Will notify the delegate with the `Response` object on success or with `Error` on error.
  func signIn(with nonce: Nonce?) {
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
    controller.presentationContextProvider = self
    controller.performRequests()
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  func signOut() {
    storage.removeObject(forKey: userIdStorageKey)
  }
  
  /// Checks the current auth state and delegates the response.
  func checkAuthorizationState() {
    guard let userId = storage.string(forKey: userIdStorageKey) else {
      delegate?.appleAuthProviderIsAuthorized(false)
      return
    }
    
    authProvider.getCredentialState(forUserID: userId) { [weak self] state, _ in
      self?.delegate?.appleAuthProviderIsAuthorized(state == .authorized)
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
      storage.set(credential.user, forKey: userIdStorageKey)
      
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

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleAuthProvider: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    presentationAnchor ?? UIWindow()
  }
}

// MARK: - Private Methods
private extension AppleAuthProvider {
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
    delegate?.appleAuthProviderIsAuthorized(false)
  }
}

// MARK: - Private String Extension Methods
private extension String {
  var sha256: String {
    SHA256
      .hash(data: Data(utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}

//
//  SignInWithApple.swift
//  PovioKit
//
//  Created by Borut Tomažin on 27/10/2020.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AuthenticationServices
import CryptoKit
import Foundation

@available(iOS 13.0, *)
protocol SignInWithAppleProtocol: AnyObject {
  /// Starts the authorization flow
  func authorizeSignIn(with nonce: SignInWithApple.Nonce?)
  /// Check if user is already authorized
  func checkAuthorizationState()
  /// We need to reset authorization state when changing user, e.g. on user sign out.
  /// This is important step otherwise `checkAuthorizationState` method will report false-positive state.
  func resetAuthorizationState()
}

@available(iOS 13.0, *)
protocol SignInWithAppleDelegate: AnyObject {
  func signInWithAppleDidAuthorize(token: String, nonce: String, displayName: String?)
  func signInWithAppleDidFail(with error: Error)
  func signInWithAppleCredentialsRevoked()
}

@available(iOS 13.0, *)
class SignInWithApple: NSObject {
  weak var delegate: SignInWithAppleDelegate?
  private let presentationAnchor: ASPresentationAnchor?
  private var currentNonce: String?
  private let userIdStorageKey = "povioKit.signInWithApple.userId"
  
  /// Class initializer with optional `presentationAnchor` param. You should usually pass the main window.
  /// If you don't pass it, `UIWindow()` is created manually for it.
  init(with presentationAnchor: ASPresentationAnchor? = nil) {
    self.presentationAnchor = presentationAnchor
    super.init()
    setupCredentialsRevokeListener()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Public Methods
@available(iOS 13.0, *)
extension SignInWithApple: SignInWithAppleProtocol {
  func authorizeSignIn(with nonce: Nonce?) {
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]
    
    switch nonce {
    case .random(let length):
      let nonceString = generateRandomNonceString(length: length)
      currentNonce = nonceString
      request.nonce = nonceString.sha256
    case .none:
      break
    }
    
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }
  
  func checkAuthorizationState() {
    guard let userId = UserDefaults.standard.string(forKey: userIdStorageKey) else { return }
    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { [weak self] state, _ in
      switch state {
      case .revoked, .notFound, .transferred:
        self?.delegate?.signInWithAppleCredentialsRevoked()
      case .authorized:
        break
      @unknown default:
        break
      }
    }
  }
  
  func resetAuthorizationState() {
    UserDefaults.standard.removeObject(forKey: userIdStorageKey)
  }
}

// MARK: - ASAuthorizationControllerDelegate
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let credential as ASAuthorizationAppleIDCredential:
      guard let nonce = currentNonce else {
        Logger.error("Missing nonce!")
        delegate?.signInWithAppleDidFail(with: Error.missingNonce)
        return
      }
      guard let identityToken = credential.identityToken else {
        Logger.error("Missing identity token!")
        delegate?.signInWithAppleDidFail(with: Error.missingIdentityToken)
        return
      }
      guard let identityTokenString = String(data: identityToken, encoding: .utf8) else {
        Logger.error("Invalid identity token!", params: ["error": identityToken.debugDescription])
        delegate?.signInWithAppleDidFail(with: Error.invalidIdentityToken)
        return
      }
      
      // store userId for later
      UserDefaults.standard.set(credential.user, forKey: userIdStorageKey)
      
      let displayName = [credential.fullName?.givenName, credential.fullName?.familyName]
        .compactMap { $0 }
        .joined(separator: " ")
      
      delegate?.signInWithAppleDidAuthorize(token: identityTokenString,
                                                  nonce: nonce,
                                                  displayName: displayName)
    case _:
      Logger.error("Unhandled authorization!")
      delegate?.signInWithAppleDidFail(with: Error.unhandledAuthorization)
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Swift.Error) {
    Logger.error("Sign in with Apple failed", params: ["error": error.localizedDescription])
    delegate?.signInWithAppleDidFail(with: error)
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    presentationAnchor ?? UIWindow()
  }
}

// MARK: - Private Methods
@available(iOS 13.0, *)
private extension SignInWithApple {
  func generateRandomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
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
@available(iOS 13.0, *)
private extension SignInWithApple {
  @objc func appleCredentialRevoked() {
    delegate?.signInWithAppleCredentialsRevoked()
  }
}

// MARK: - Private String Extension Methods
@available(iOS 13.0, *)
private extension String {
  var sha256: String {
    SHA256
      .hash(data: Data(utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}

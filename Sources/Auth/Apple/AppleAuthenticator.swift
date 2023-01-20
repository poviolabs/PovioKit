//
//  AppleAuthenticator.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/10/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import PovioKitAuthCore
import PovioKitPromise

public protocol AppleAuthProvidable: AuthProvidable {
  func signIn(from presentingViewController: UIViewController,
              with nonce: AppleAuthenticator.Nonce) -> Promise<Response>
  func checkAuthState() -> Promise<AuthProvidable.Authenticated>
}

public final class AppleAuthenticator: NSObject {
  private let userIdStorageKey = "povioKit.appleSocialProvider.signIn.userId"
  private let storage: UserDefaults = .standard
  private let provider: ASAuthorizationAppleIDProvider
  private var processingPromise: Promise<Response>?
  
  public override init() {
    self.provider = .init()
    super.init()
    setupCredentialsRevokeListener()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Public Methods
extension AppleAuthenticator: AppleAuthProvidable {
  /// SignIn user
  ///
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(from presentingViewController: UIViewController) -> Promise<Response> {
    let promise = Promise<Response>()
    processingPromise = promise
    appleSignIn(on: presentingViewController, with: nil)
    return promise
  }
  
  /// SignIn user with `nonce` value
  ///
  /// Nonce is usually needed when doing auth with an external auth provider (e.g. firebase).
  /// Will return promise with the `Response` object on success or with `Error` on error.
  public func signIn(from presentingViewController: UIViewController, with nonce: Nonce) -> Promise<Response> {
    let promise = Promise<Response>()
    processingPromise = promise
    appleSignIn(on: presentingViewController, with: nonce)
    return promise
  }
  
  /// Clears the signIn footprint and logs out the user immediatelly.
  public func signOut() {
    storage.removeObject(forKey: userIdStorageKey)
  }
  
  /// Checks the current auth state and returns the boolean value as promise.
  public func checkAuthState() -> Promise<Authenticated> {
    guard let userId = storage.string(forKey: userIdStorageKey) else {
      return .value(false)
    }
    
    return Promise { seal in
      ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { credentialsState, _ in
        seal.resolve(with: credentialsState == .authorized)
      }
    }
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthenticator: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let credential as ASAuthorizationAppleIDCredential:
      guard let identityToken = credential.identityToken,
            let identityTokenString = String(data: identityToken, encoding: .utf8) else {
        processingPromise?.reject(with: Authenticator.Error.invalidIdentityToken)
        return
      }
      
      // store userId for later
      storage.set(credential.user, forKey: userIdStorageKey)
      
      // parse email and related metadata
      let email: Authenticator.Response.Email? = credential.email.map {
        let identity = try? JWTDecoder(token: identityTokenString)
        let isEmailPrivate = identity?.bool(for: "is_private_email")
        let isEmailVerified = identity?.bool(for: "email_verified")
        
        return .init($0, isPrivate: isEmailPrivate, isVerified: isEmailVerified)
      }
      
      // make response
      let response = Response(token: identityTokenString,
                              name: credential.displayName,
                              email: email)
      
      // resolve promise
      processingPromise?.resolve(with: response)
    case _:
      processingPromise?.reject(with: Authenticator.Error.unhandledAuthorization)
      break
    }
  }
  
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Swift.Error) {
    processingPromise?.reject(with: Authenticator.Error.system(error))
  }
}

// MARK: - Private Methods
private extension AppleAuthenticator {
  func appleSignIn(on presentingViewController: UIViewController, with nonce: Nonce?) {
    let request = provider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    switch nonce {
    case .random(let length):
      guard length > 0 else {
        processingPromise?.reject(with: Authenticator.Error.invalidNonceLength)
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
private extension AppleAuthenticator {
  @objc func appleCredentialRevoked() {
    processingPromise?.reject(with: Authenticator.Error.credentialsRevoked)
  }
}

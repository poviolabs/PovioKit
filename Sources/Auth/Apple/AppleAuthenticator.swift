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

public final class AppleAuthenticator: NSObject {
  private let storage: UserDefaults
  private let storageUserIdKey = "signIn.userId"
  private let storageAuthenticatedKey = "authenticated"
  private let provider: ASAuthorizationAppleIDProvider
  private var processingPromise: Promise<Response>?
  
  public init(storage: UserDefaults? = nil) {
    self.provider = .init()
    self.storage = storage ?? .init(suiteName: "povioKit.auth.apple") ?? .standard
    super.init()
    setupCredentialsRevokeListener()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Public Methods
extension AppleAuthenticator: Authenticator {
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
    storage.removeObject(forKey: storageUserIdKey)
    rejectSignIn(with: .cancelled)
  }
  
  /// Returns the current authentication state.
  public var isAuthenticated: Authenticated {
    storage.string(forKey: storageUserIdKey) != nil && storage.bool(forKey: storageAuthenticatedKey)
  }
  
  /// Checks the current auth state and returns the boolean value as promise.
  public var checkAuthentication: Promise<Authenticated> {
    guard let userId = storage.string(forKey: storageUserIdKey) else {
      return .value(false)
    }
    
    return Promise { seal in
      ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { credentialsState, _ in
        seal.resolve(with: credentialsState == .authorized)
      }
    }
  }
  
  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  public func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    false
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthenticator: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let credential as ASAuthorizationAppleIDCredential:
      guard let identityToken = credential.identityToken,
            let identityTokenString = String(data: identityToken, encoding: .utf8) else {
        rejectSignIn(with: .invalidIdentityToken)
        return
      }
      
      // store userId and authentication flag
      storage.set(credential.user, forKey: storageUserIdKey)
      storage.setValue(true, forKey: storageAuthenticatedKey)
      
      // parse email and related metadata
      let email: Response.Email? = credential.email.map {
        let identity = try? JWTDecoder(token: identityTokenString)
        let isEmailPrivate = identity?.bool(for: "is_private_email") ?? false
        let isEmailVerified = identity?.bool(for: "email_verified") ?? false
        return .init(address: $0, isPrivate: isEmailPrivate, isVerified: isEmailVerified)
      }
      
      let response = Response(token: identityTokenString,
                              name: credential.displayName,
                              email: email)
      
      processingPromise?.resolve(with: response)
    case _:
      rejectSignIn(with: .unhandledAuthorization)
    }
  }
  
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Swift.Error) {
    rejectSignIn(with: .system(error))
  }
}

// MARK: - Error
public extension AppleAuthenticator {
  enum Error: Swift.Error {
    case system(_ error: Swift.Error)
    case cancelled
    case invalidNonceLength
    case invalidIdentityToken
    case unhandledAuthorization
    case credentialsRevoked
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
        rejectSignIn(with: .invalidNonceLength)
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
  
  func rejectSignIn(with error: Error) {
    storage.setValue(false, forKey: storageAuthenticatedKey)
    processingPromise?.reject(with: error)
    processingPromise = nil
  }
}

// MARK: - Actions
private extension AppleAuthenticator {
  @objc func appleCredentialRevoked() {
    rejectSignIn(with: .credentialsRevoked)
  }
}

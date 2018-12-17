//
//  SKFacebookAuthenticator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import FBSDKLoginKit

class SKFacebookAuthenticator: SKSocialMediaAuthenticator {
  private let fbsdkManager = FBSDKLoginManager()
  
  func login(from viewController: UIViewController? = nil, readPermissions: [Any]?, success: ((String) -> Void)?, failure: ((Error) -> Void)?) {
    let permissions = (readPermissions as? [Permission])?.map { $0.rawValue } ?? []
    fbsdkManager.logIn(withReadPermissions: permissions, from: viewController) { (result, error) in
      guard let token = result?.token else {
        failure?(error ?? SKSocialMediaError.userCanceled)
        return
      }
      success?(token.tokenString)
    }
  }
  
  func login(from viewController: UIViewController? = nil, writePermissions: [Any]?, success: ((String) -> Void)?, failure: ((Error) -> Void)?) {
    let permissions = (writePermissions as? [Permission])?.map { $0.rawValue } ?? []
    fbsdkManager.logIn(withPublishPermissions: permissions, from: viewController) { (result, error) in
      guard let token = result?.token else {
        guard let error = error else { return }
        failure?(error)
        return
      }
      success?(token.tokenString)
    }
  }
  
  func logout() {
    fbsdkManager.logOut()
  }
  
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
  }
}

extension SKFacebookAuthenticator {
  var isLoggedIn: Bool {
    return FBSDKAccessToken.current() != nil
  }
  
  var isAccessTokenValid: Bool {
    return FBSDKAccessToken.currentAccessTokenIsActive()
  }
  
  var applicationUrl: URL {
    return "fb://"
  }
}

extension SKFacebookAuthenticator {
  enum Permission: String {
    case email
    
    static var defaultPermissions: [Permission] {
      return [
        .email
      ]
    }
  }
}

//
//  SKSocialMediaAuthenticator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

protocol SKSocialMediaAuthenticator {
  func login(from viewController: UIViewController?, readPermissions: [Any]?, success: ((String) -> Void)?, failure: ((Error) -> Void)?)
  func login(from viewController: UIViewController?, writePermissions: [Any]?, success: ((String) -> Void)?, failure: ((Error) -> Void)?)
  func logout()
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
  
  var isLoggedIn: Bool { get }
  var isAccessTokenValid: Bool { get }
  var isApplicationInstalled: Bool { get }
  var applicationUrl: URL { get }
}

extension SKSocialMediaAuthenticator {
  var isApplicationInstalled: Bool {
    return UIApplication.shared.canOpenURL(applicationUrl)
  }
}

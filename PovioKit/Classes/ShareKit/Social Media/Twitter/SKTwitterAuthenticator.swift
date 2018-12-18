//
//  TwitterWorker.swift
//  Facelift
//
//  Created by Toni Kocjan on 17/07/2018.
//  Copyright © 2018 poviolabs. All rights reserved.
//

import TwitterKit

///
/// Utility module providing API for login / logout feature on `Twitter`.
/// NOTE: - For log in without Twitter app installed, make sure to add a `callback url` on the apps platform. The url should look like: `twitterkit-[Consumer Key]://`.
///
class SKTwitterAuthenticator: SKSocialMediaAuthenticator {
  enum TwitterLoginError: Error {
    case unknown
  }
  
  func login(from viewController: UIViewController?, readPermissions: [Any]?, success: ((String) -> Void)?, failure: ((Error) -> Void)?) {
    login(success: { session in
      success?(session.authToken)
    }, failure: failure)
  }
  
  func login(from viewController: UIViewController?, writePermissions: [Any]?, success: ((String) -> Void)?, failure: ((Error) -> Void)?) {
    login(success: { session in
      success?(session.authToken)
    }, failure: failure)
  }
  
  func login(success: ((TWTRSession) -> Void)?, failure: ((Error) -> Void)?) {
    TWTRTwitter.sharedInstance().logIn { (session, error) in
      guard let session = session else {
        failure?(error ?? TwitterLoginError.unknown)
        return
      }
      success?(session)
    }
  }
  
  func logout() {
    if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
      TWTRTwitter.sharedInstance().sessionStore.logOutUserID(session.userID)
    }
  }
  
  func canOpenUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
  }
}

extension SKTwitterAuthenticator {
  var isLoggedIn: Bool {
    return TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()
  }
  
  var isAccessTokenValid: Bool {
    return isLoggedIn
  }
  
  var applicationUrl: URL {
    return URL(string: "twitter://")!
  }
}

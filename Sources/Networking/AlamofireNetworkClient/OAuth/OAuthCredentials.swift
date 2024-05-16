//
//  OAuthCredentials.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/04/2022.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

/// Credentials container holding all necessary data for token auth and refreshing.
/// You'll need to implement an extension for this model in your project that conforms to `Alamofire.AuthenticationCredential` protocol.
/// ```
/// extension OAuthCredentials: AuthenticationCredential {
///   var requiresRefresh: Bool {
///     // logic to determine if token is expired and needs to be refreshed
///   }
/// }
/// ```
public struct OAuthCredentials {
  public let accessToken: String
  public let refreshToken: String
  public let expiresAt: Date?
}

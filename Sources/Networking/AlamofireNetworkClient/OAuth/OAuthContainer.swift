//
//  OAuthRequestInterceptor.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/04/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public struct OAuthContainer {
  public let accessToken: String
  public let refreshToken: String
  
  public init(
    accessToken: String,
    refreshToken: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

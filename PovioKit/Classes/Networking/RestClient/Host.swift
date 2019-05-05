//
//  Host.swift
//  PovioKit
//
//  Created by Borut Tomažin on 14/01/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public enum Host {
  case development
  case production
}

public extension Host {
  var baseURL: String {
    switch self {
    case .development:
      return "https://us-central1-waybots-a2558.cloudfunctions.net"
    case .production:
      return "https://us-central1-waybots-production.cloudfunctions.net"
    }
  }
  
  var name: String {
    switch self {
    case .development:
      return "DEV"
    case .production:
      return "PROD"
    }
  }
  
  static var current: Host {
    return Constants.Environment.isDevTarget ? .development : .production
  }
}

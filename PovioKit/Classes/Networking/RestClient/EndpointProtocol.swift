//
//  EndpointProtocol.swift
//  PovioKit
//
//  Created by Toni Kocjan on 18/03/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public protocol EndpointProtocol {
  typealias Path = String
  var path: Path { get }
  var url: String { get }
  var retryCount: Int { get }
  var apiVersion: Version { get }
  var authentication: Authentication { get }
  var clientToken: String? { get }
}

extension EndpointProtocol where Self: RawRepresentable, Self.RawValue == String {
  public var path: String {
    return rawValue
  }
}

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
  var path: String { get }
}

extension EndpointProtocol where Self: RawRepresentable, Self.RawValue == String {
  public var path: String {
    return rawValue
  }
}

//
//  XCConfigValue.swift
//  PovioKit
//
//  Created by Egzon Arifi on 30/03/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct XCConfigValue<Value: LosslessStringConvertible> {
  private let key: String
  private let bundle: Bundle
  
  public var wrappedValue: Value {
    value(for: key)
  }
  
  public init(key: String,
              bundle: Bundle = .main) {
    self.key = key
    self.bundle = bundle
  }
}

private extension XCConfigValue {
  func value(for key: String) -> Value {
    guard let object = bundle.object(forInfoDictionaryKey: key) else {
      fatalError("Missing key: \(key)")
    }
    
    switch object {
    case let value as Value:
      return value
      
    case let string as String:
      guard let value = Value(string) else { fallthrough }
      return value
      
    default:
      fatalError("Invalid Value")
    }
  }
}

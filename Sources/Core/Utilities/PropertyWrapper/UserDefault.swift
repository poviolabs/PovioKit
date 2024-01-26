//
//  UserDefault.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

private protocol OptionalProtocol {
  func isNil() -> Bool
}

extension Optional : OptionalProtocol {
  func isNil() -> Bool {
    return self == nil
  }
}

@propertyWrapper public struct UserDefault<Value> {
  private let key: String
  private let defaultValue: Value
  private let storage: UserDefaults

  public var wrappedValue: Value {
    get {
      guard let value = storage.object(forKey: key) else {
        return defaultValue
      }
      
      return value as? Value ?? defaultValue
    }
    set {
      if let value = newValue as? OptionalProtocol, value.isNil() {
        storage.removeObject(forKey: key)
      } else {
        storage.set(newValue, forKey: key)
      }
    }
  }
  
  public init(defaultValue: Value,
              key: String,
              storage: UserDefaults = .standard) {
    self.defaultValue = defaultValue
    self.key = key
    self.storage = storage
  }
}

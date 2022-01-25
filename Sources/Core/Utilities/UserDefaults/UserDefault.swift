//
//  UserDefault.swift
//  
//
//  Created by Egzon Arifi on 25/01/2022.
//

import Foundation

@propertyWrapper public struct UserDefault<Value> {
  private let key: String
  private let defaultValue: Value
  private let storage: UserDefaults
  
  public var wrappedValue: Value {
    get {
      let value = storage.value(forKey: key) as? Value
      return value ?? defaultValue
    }
    set {
      storage.setValue(newValue, forKey: key)
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

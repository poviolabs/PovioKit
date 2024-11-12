//
//  UserDefault.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<Value: Codable> {
  private let storage: UserDefaults
  private let keyObject: UserDefaultKey<Value>
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder
  
  public var wrappedValue: Value {
    get {
      guard let data = storage.data(forKey: keyObject.key) else { return keyObject.defaultValue }
      let value = try? decoder.decode(Value.self, from: data)
      return value ?? keyObject.defaultValue
    }
    set {
      if let encoded = try? encoder.encode(newValue) {
        storage.set(encoded, forKey: keyObject.key)
      }
    }
  }
  
  public init(defaultValue: Value,
              key: String,
              storage: UserDefaults = .standard,
              encoder: JSONEncoder = .init(),
              decoder: JSONDecoder = .init()) {
    self.storage = storage
    self.encoder = encoder
    self.decoder = decoder
    self.keyObject = UserDefaultKey(key: key,
                                    defaultValue: defaultValue,
                                    storage: storage,
                                    encoder: encoder)
  }
  
  public var projectedValue: UserDefaultKey<Value> {
    keyObject
  }
}

public class UserDefaultKey<Value: Codable> {
  let key: String
  let defaultValue: Value
  let storage: UserDefaults
  let encoder: JSONEncoder
  
  init(key: String,
       defaultValue: Value,
       storage: UserDefaults,
       encoder: JSONEncoder) {
    self.key = key
    self.defaultValue = defaultValue
    self.storage = storage
    self.encoder = encoder
  }
  
  public func resetValue() {
    guard let encoded = try? encoder.encode(defaultValue) else { return }
    storage.set(encoded, forKey: key)
  }
}

//
//  Promise.swift
//  PovioKit
//
//  Created by Toni Kocjan on 28/02/2019.
//  Copyright © 2019 PovioLabs. All rights reserved.
//

import Foundation

public class Promise<Value, Error: Swift.Error>: Future<Value, Error> {
  public override init() {
    super.init()
  }
  
  public init(fulfil value: Value) {
    super.init()
    result = .success(value)
  }
  
  public init(reject error: Error) {
    super.init()
    result = .failure(error)
  }
  
  public func resolve(with value: Value) {
    result = .success(value)
  }
  
  public func reject(with error: Error) {
    result = .failure(error)
  }
}

public extension Promise {
  var isFulfiled: Bool {
    switch result {
    case .success?:
      return true
    case .failure?, .none:
      return false
    }
  }
  
  var isRejected: Bool {
    switch result {
    case .failure?:
      return true
    case .success?, .none:
      return false
    }
  }
  
  var isAwaiting: Bool {
    return result == nil
  }
  
  var value: Value? {
    switch result {
    case .success(let value)?:
      return value
    case .failure?, .none:
      return nil
    }
  }
  
  var error: Error? {
    switch result {
    case .failure(let error)?:
      return error
    case .success?, .none:
      return nil
    }
  }
}

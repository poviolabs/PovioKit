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
  
  public init(fulfill value: Value) {
    super.init()
    result = .success(value)
  }
  
  public init(reject error: Error) {
    super.init()
    result = .failure(error)
  }
  
  convenience init(_ future: (Promise) -> Void) {
    self.init()
    future(self)
  }
  
  public func resolve(with value: Value) {
    guard !isFulfilled else { return }
    result = .success(value)
  }
  
  public func reject(with error: Error) {
    guard !isRejected else { return }
    result = .failure(error)
  }
  
  public func resolve(with result: Result<Value, Error>) {
    switch result {
    case .success(let value):
      resolve(with: value)
    case .failure(let error):
      reject(with: error)
    }
  }
}

public extension Promise {
  func map<TransformedValue>(with transform: @escaping (Value) -> TransformedValue) -> Promise<TransformedValue, Error> {
    return chain {
      return Promise<TransformedValue, Error>(fulfill: transform($0))
    }
  }
  
  func mapError<TransformedError>(with transform: @escaping (Error) -> TransformedError) -> Promise<Value, TransformedError> where TransformedError: Swift.Error {
    let result = Promise<Value, TransformedError>()
    observe {
      switch $0 {
      case .success(let value):
        result.resolve(with: value)
      case .failure(let error):
        result.reject(with: transform(error))
      }
    }
    return result
  }
  
  func mapResult<ChainedValue>(with transform: @escaping (Value) -> Result<ChainedValue, Error>) -> Promise<ChainedValue, Error> {
    let result = Promise<ChainedValue, Error>()
    observe {
      switch $0 {
      case .success(let value):
        result.resolve(with: transform(value))
      case .failure(let error):
        result.reject(with: error)
      }
    }
    return result
  }
  
  func chain<ChainedValue>(with transform: @escaping (Value) -> Promise<ChainedValue, Error>) -> Promise<ChainedValue, Error> {
    let result = Promise<ChainedValue, Error>()
    observe {
      switch $0 {
      case .success(let value):
        let promise = transform(value)
        promise.observe { res in
          switch res {
          case .success(let value):
            result.resolve(with: value)
          case .failure(let error):
            result.reject(with: error)
          }
        }
      case .failure(let error):
        result.reject(with: error)
      }
    }
    return result
  }
  
  func chain<ChainedValue, ChainedError: Swift.Error>(with transform: @escaping (Value) -> Promise<ChainedValue, ChainedError>,
                                                      transformError: @escaping (Error) -> ChainedError) -> Promise<ChainedValue, ChainedError> {
    let result = Promise<ChainedValue, ChainedError>()
    observe {
      switch $0 {
      case .success(let value):
        let promise = transform(value)
        promise.observe { res in
          switch res {
          case .success(let value):
            result.resolve(with: value)
          case .failure(let error):
            result.reject(with: error)
          }
        }
      case .failure(let error):
        result.reject(with: transformError(error))
      }
    }
    return result
  }
  
  func observe(promise: Promise) {
    promise.onSuccess(resolve)
    promise.onFailure(reject)
  }
}

public extension Promise {
  var isFulfilled: Bool {
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

extension Promise where Value == Void {
  func resolve() {
    resolve(with: ())
  }
}

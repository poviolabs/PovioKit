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
  
  public convenience init(_ future: (Promise) -> Void) {
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
  
  /// Returns a new promise, mapping any success value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a success.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `Promise` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  func map<NewValue>(with transform: @escaping (Value) -> NewValue) -> Promise<NewValue, Error> {
    return chain {
      return Promise<NewValue, Error>(fulfill: transform($0))
    }
  }
  
  /// Returns a new promise, mapping any failure value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a failure.
  ///
  /// - Parameter transform: A closure that takes the failure value of this
  ///   instance.
  /// - Returns: A `Promise` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  func mapError<NewError>(with transform: @escaping (Error) -> NewError) -> Promise<Value, NewError> where NewError: Swift.Error {
    let result = Promise<Value, NewError>()
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
  
  /// Returns a new promise, mapping any success value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Promise`
  /// instance when it represents a success.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `Promise` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  func mapResult<NewValue>(with transform: @escaping (Value) -> Result<NewValue, Error>) -> Promise<NewValue, Error> {
    let result = Promise<NewValue, Error>()
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
                                                      transformError: @escaping (ChainedError) -> Error) -> Promise<ChainedValue, Error> {
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
            result.reject(with: transformError(error))
          }
        }
      case .failure(let error):
        result.reject(with: error)
      }
    }
    return result
  }
  
  func observe(promise: Promise) {
    promise.onSuccess(resolve)
    promise.onFailure(reject)
  }
  
  /// Returns a new promise, combining n `Promise`.
  ///
  /// Use this method when you need to combine array `[Promise]` of the same type and run it concurrently.
  ///
  /// - Parameter promises: A list of `Promises` that you want to combine.
  /// - Returns: A `Promise` instance with the result of an array of all the values of the combined promises.
  static func combine(promises: [Promise<Value, Error>]) -> Promise<[Value], Error> {
    return Promise<[Value], Error> { finalPromise in
      let combineQueue = DispatchQueue(label: "combineQueue", attributes: .concurrent)
      for promise in promises {
        promise.observe { result in
          combineQueue.async(flags: .barrier) {
            switch result {
            case .success:
              if areAllFulfilled(promises) {
                finalPromise.resolve(with: allResults(for: promises))
              }
            case .failure(let error):
              finalPromise.reject(with: error)
            }
          }
        }
      }
    }
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

public extension Promise where Value == Void {
  func resolve() {
    resolve(with: ())
  }
}

// MARK: - Private methods
private extension Promise {
  static func areAllFulfilled(_ promises: [Promise<Value, Error>]) -> Bool {
    promises.allSatisfy { $0.isFulfilled }
  }
  
  static func allResults(for promises: [Promise<Value, Error>]) -> [Value] {
    promises.compactMap { $0.value }
  }
}

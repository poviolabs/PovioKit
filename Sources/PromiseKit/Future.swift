//
//  Future.swift
//  PovioKit
//
//  Created by Toni Kocjan on 04/03/2019.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public class Future<Value, Error: Swift.Error> {
  private let barrier = DispatchQueue(label: "com.poviokit.future", attributes: .concurrent)
  private var observers = [Observer]()
  public var isEnabled = true
  private var internalResult: FutureResult?
}

public extension Future {
  var result: FutureResult? {
    barrier.sync { internalResult }
  }
  
  func setResult(_ result: FutureResult?, on dispatchQueue: DispatchQueue? = nil) {
    barrier.sync(flags: .barrier) {
      internalResult = result
      guard isEnabled else { return }
      dispatchQueue.async {
        result.map { value in self.observers.forEach { $0.notifity(value) } }
      }
    }
  }
}

public extension Future {
  typealias FutureResult = Result<Value, Error>
  
  func finally(with callback: @escaping (FutureResult) -> Void) {
    barrier.sync(flags: .barrier) {
      observers.append(.both(callback))
      internalResult.map(callback)
    }
  }
  
  func then(_ callback: @escaping (Value) -> Void) {
    barrier.sync(flags: .barrier) {
      observers.append(.success(callback))
      internalResult.map { observers.last?.notifity($0) }
    }
  }
  
  func `catch`(_ callback: @escaping (Error) -> Void) {
    barrier.sync(flags: .barrier) {
      observers.append(.failure(callback))
      internalResult.map { observers.last?.notifity($0) }
    }
  }
  
  @available(*, deprecated, renamed: "finally")
  @inline(__always)
  func observe(with callback: @escaping (FutureResult) -> Void) {
    self.finally(with: callback)
  }
  
  @available(*, deprecated, renamed: "then")
  @inline(__always)
  func onSuccess(_ callback: @escaping (Value) -> Void) {
    self.then(callback)
  }
  
  @available(*, deprecated, renamed: "catch")
  @inline(__always)
  func onFailure(_ callback: @escaping (Error) -> Void) {
    self.catch(callback)
  }
}

private extension Future {
  enum Observer {
    case success((Value) -> Void)
    case failure((Error) -> Void)
    case both((FutureResult) -> Void)
    
    func notifity(_ result: FutureResult) {
      switch (self, result) {
      case (.both(let closure), _):
        closure(result)
      case let (.success(closure), .success(value)):
        closure(value)
      case let (.failure(closure), .failure(error)):
        closure(error)
      default:
        break
      }
    }
  }
}

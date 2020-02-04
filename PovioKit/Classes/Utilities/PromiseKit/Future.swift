//
//  Future.swift
//  PovioKit
//
//  Created by Toni Kocjan on 04/03/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
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
    var res: FutureResult?
    barrier.sync {
      res = internalResult
    }
    return res
  }
  
  func setResult(_ result: FutureResult?, on dispatchQueue: DispatchQueue? = nil) {
    barrier.sync(flags: .barrier) {
      self.internalResult = result
      guard self.isEnabled else { return }
      dispatchQueue.async {
        result.map { value in self.observers.forEach { $0.notifity(value) } }
      }
    }
  }
}

public extension Future {
  typealias FutureResult = Result<Value, Error>
  
  func observe(with callback: @escaping (FutureResult) -> Void) {
    barrier.sync(flags: .barrier) {
      self.observers.append(.both(callback))
      self.internalResult.map(callback)
    }
  }
  
  func onSuccess(_ callback: @escaping (Value) -> Void) {
    barrier.sync(flags: .barrier) {
      self.observers.append(.success(callback))
      self.internalResult.map { self.observers.last?.notifity($0) }
    }
  }
  
  func onFailure(_ callback: @escaping (Error) -> Void) {
    barrier.sync(flags: .barrier) {
      self.observers.append(.failure(callback))
      self.internalResult.map { self.observers.last?.notifity($0) }
    }
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

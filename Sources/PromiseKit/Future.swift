//
//  Future.swift
//  PovioKit
//
//  Created by Toni Kocjan on 04/03/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public class Future<Value, Error: Swift.Error> {
  private let lock = NSLock()
  private var observers = [Observer]()
  public var isEnabled = true
  private var internalResult: FutureResult?
}

internal extension Future {
  var result: FutureResult? {
    lock.withLock {
      internalResult
    }
  }
  
  func setResult(_ result: FutureResult?, on dispatchQueue: DispatchQueue? = nil) {
    lock.withLock {
      guard self.internalResult == nil else { return }
      self.internalResult = result
      guard self.isEnabled, let result = result else { return }
      for observer in self.observers {
        dispatchQueue.async { observer.notifity(result) }
      }
    }
  }
}

public extension Future {
  typealias FutureResult = Result<Value, Error>
  
  func finally(with callback: @escaping (FutureResult) -> Void) {
    lock.withLock {
      self.observers.append(.both(callback))
      self.internalResult.map(callback)
    }
  }
  
  func then(_ callback: @escaping (Value) -> Void) {
    lock.withLock {
      self.observers.append(.success(callback))
      self.internalResult.map { self.observers.last?.notifity($0) }
    }
  }
  
  func `catch`(_ callback: @escaping (Error) -> Void) {
    lock.withLock {
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

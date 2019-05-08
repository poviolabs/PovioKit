//
//  Future.swift
//  PovioKit
//
//  Created by Toni Kocjan on 04/03/2019.
//  Copyright © 2019 Povio Labs Inc. All rights reserved.
//

import Foundation

public class Future<Value, Error: Swift.Error> {
  private var observers = [Observer]()
  public var result: FutureResult? {
    didSet { result.map(invokeObservers) }
  }
}

public extension Future {
  typealias FutureResult = Result<Value, Error>
  
  func observe(with callback: @escaping (FutureResult) -> Void) {
    observers.append(.both(callback))
    result.map(callback)
  }
  
  func onSuccess(_ callback: @escaping (Value) -> Void) {
    observers.append(.success(callback))
    result.map { observers.last?.notifity($0) }
  }
  
  func onFailure(_ callback: @escaping (Error) -> Void) {
    observers.append(.failure(callback))
    result.map { observers.last?.notifity($0) }
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
  
  func invokeObservers(_ result: FutureResult) {
    DispatchQueue.main.async { self.observers.forEach { $0.notifity(result) } }
  }
}

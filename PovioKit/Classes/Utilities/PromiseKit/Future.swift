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
  typealias Observer = (FutureResult) -> Void
  
  func observe(with callback: @escaping Observer) {
    observers.append(callback)
    result.map(callback)
  }
  
  private func invokeObservers(_ result: FutureResult) {
    DispatchQueue.main.async { self.observers.forEach { $0(result) } }
  }
}

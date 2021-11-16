//
//  CancelablePromise.swift
//  
//
//  Created by Toni Kocjan on 16/11/2021.
//

import Foundation

public protocol Cancelable {
  func cancel()
}


public class CancelablePromise<Value>: Promise<Value> {
  let cancelable: Cancelable
  
  public init(cancelable: Cancelable) {
    self.cancelable = cancelable
    super.init()
  }
  
  public convenience init(cancelable: Cancelable, _ future: (CancelablePromise) -> Void) {
    self.init(cancelable: cancelable)
    future(self)
  }
}

public extension CancelablePromise {
  func cancel() {
    barrier.sync(execute: cancelable.cancel)
  }
}

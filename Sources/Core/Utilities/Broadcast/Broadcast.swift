//
//  Broadcast.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public final class Broadcast<T: AnyObject> {
  private(set) var observers = [Weak<T>]()

  public init() {}
  
  public func add(delegate: T) {
    prune()
    observers.append(.init(delegate))
  }
  
  public func remove(delegate: T) {
    prune()
    let index = observers.firstIndex {
      $0.reference === delegate
    }
    if let index {
      observers.remove(at: index)
    }
  }
  
  public func invoke(invocation: (T) -> Void) {
    observers.reversed().forEach {
      guard let delegate = $0.reference else { return }
      invocation(delegate)
    }
  }
  
  public func invoke(
    on queue: DispatchQueue = .main,
    invocation: @escaping (T) -> Void
  ) {
    queue.async {
      self.invoke(invocation: invocation)
    }
  }
  
  public func clear() {
    observers.removeAll()
  }
}

extension Broadcast {
  class Weak<U: AnyObject> {
    weak var reference: U?
    
    init(_ object: U) { 
      self.reference = object 
    }
  }
}

private extension Broadcast {
  func prune() {
    observers.removeAll { $0.reference == nil }
  }
}

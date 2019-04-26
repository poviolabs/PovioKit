//
//  Broadcast.swift
//  TSS
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2018 Povio Inc. All rights reserved.
//

import Foundation

public class Broadcast<T> {
  class Weak<T: AnyObject> {
    weak var reference: T?
    init(_ object: T) { self.reference = object }
  }
  
  private(set) var delegates = [Weak<AnyObject>]()
  
  func add(delegate: T) {
    prune()
    delegates.append(Weak<AnyObject>(delegate as AnyObject))
  }
  
  func remove(delegate: T) {
    prune()
    guard let index = delegates.firstIndex(where: {
      guard let reference = $0.reference else { return false }
      return reference === delegate as AnyObject
    }) else { return }
    delegates.remove(at: index)
  }
  
  func invoke(invocation: (T) -> Void) {
    delegates.reversed().forEach {
      guard let delegate = $0.reference as? T else { return }
      invocation(delegate)
    }
  }
  
  func invoke(on queue: DispatchQueue = .main, invocation: @escaping (T) -> Void) {
    queue.async {
      self.invoke(invocation: invocation)
    }
  }
  
  func clear() {
    delegates.removeAll()
  }
  
  private func prune() {
    delegates = delegates.filter { $0.reference != nil }
  }
}

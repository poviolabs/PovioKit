//
//  Delegated.swift
//  PovioKit
//
//  Created by Toni Kocjan on 20/07/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

@dynamicCallable
public struct Delegated<Input, Output> {
  typealias Callback = (Input) -> Output
  private var callback: Callback = { _ in fatalError("Implement the delegate method") }
  
  public mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?, Input) -> Output) {
    self.callback = { [weak object] input in
      callback(object, input)
    }
  }
  
  public func dynamicallyCall(withArguments args: [Input]) -> Output {
    assert(!args.isEmpty, "Must provide arguments to a non-void callback!")
    return callback(args[0])
  }
}

public extension Delegated where Input == Void {
  mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?) -> Output) {
    self.callback = { [weak object] _ in
      callback(object)
    }
  }
  
  func dynamicallyCall(withArguments args: [Void]) -> Output {
    return callback(())
  }
}

public extension Delegated where Input == Void, Output == Void {
  mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?) -> Void) {
    self.callback = { [weak object] _ in
      callback(object)
    }
  }
  
  func dynamicallyCall(withArguments args: [Void]) {
    callback(())
  }
}

public typealias VoidDelegate = Delegated<Void, Void>

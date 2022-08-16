//
//  Future.swift
//  PovioKit
//
//  Created by Toni Kocjan on 04/03/2019.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public class Future<Value, Error: Swift.Error> {
//  private let lock = DispatchQueue(label: "com.poviokit.future", attributes: .concurrent)
  private let lock = NSLock()
//  private let lock = RWLock()
//  private let lock = Mutex()
  private var observers = [Observer]()
  public var isEnabled = true
  private var internalResult: FutureResult?
}

public extension Future {
  var result: FutureResult? {
    read {
      internalResult
    }
  }
  
  func setResult(_ result: FutureResult?, on dispatchQueue: DispatchQueue? = nil) {
    write {
      self.internalResult = result
      guard self.isEnabled, let result = result else { return }
      dispatchQueue.async {
        self.observers.forEach { $0.notifity(result) }
      }
    }
  }
}

public extension Future {
  typealias FutureResult = Result<Value, Error>
  
  func finally(with callback: @escaping (FutureResult) -> Void) {
    write {
      self.observers.append(.both(callback))
      self.internalResult.map(callback)
    }
  }
  
  func then(_ callback: @escaping (Value) -> Void) {
    write {
      self.observers.append(.success(callback))
      self.internalResult.map { self.observers.last?.notifity($0) }
    }
  }
  
  func `catch`(_ callback: @escaping (Error) -> Void) {
    write {
      self.observers.append(.failure(callback))
      self.internalResult.map { self.observers.last?.notifity($0) }
    }
  }
  
  @inline(__always)
  func write(_ work: @escaping () -> Void) {
    lock.write(work)
  }
  
  @inline(__always)
  func read<T>(_ work: () -> T) -> T {
    lock.read(work)
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

final class Mutex {
  private var mutex: pthread_mutex_t = {
    var mutex = pthread_mutex_t()
    pthread_mutex_init(&mutex, nil)
    return mutex
  }()
  
  @inline(__always)
  func read<T>(_ work: () -> T) -> T {
    lock()
    defer { unlock() }
    return work()
  }
  
  @inline(__always)
  func write(_ work: () -> Void) {
    lock()
    defer { unlock() }
    return work()
  }
  
  func lock() {
    pthread_mutex_lock(&mutex)
  }
  
  func unlock() {
    pthread_mutex_unlock(&mutex)
  }
}

final class RWLock {
  private(set) var lock: pthread_rwlock_t = {
    var lock = pthread_rwlock_t()
    pthread_rwlock_init(&lock, nil)
    return lock
  }()
  
  @inline(__always)
  func read<T>(_ work: () -> T) -> T {
    pthread_rwlock_rdlock(&lock)
    defer { pthread_rwlock_unlock(&lock) }
    return work()
  }
  
  @inline(__always)
  func write(_ work: () -> Void) {
    pthread_rwlock_wrlock(&lock)
    defer { pthread_rwlock_unlock(&lock) }
    return work()
  }
}

extension NSLock {
  @inline(__always)
  func read<T>(_ work: () -> T) -> T {
    lock()
    defer { unlock() }
    return work()
  }
  
  @inline(__always)
  func write(_ work: () -> Void) {
    lock()
    defer { unlock() }
    return work()
  }
}

extension DispatchQueue {
  @inline(__always)
  func read<T>(_ work: () -> T) -> T {
    sync(execute: work)
  }
  
  @inline(__always)
  func write(_ work: @escaping () -> Void) {
    sync(flags: .barrier, execute: work)
  }
}

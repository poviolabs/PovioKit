//
//  Sequence.swift
//  
//
//  Created by Toni K. Turk on 08/08/2022.
//

import Foundation

/// Execute a series of tasks in a sequence. A new task
/// is spawned once the previous one succeeds. If a task tails,
/// it can (optionally) be retried for several times, depending on the
/// `retryCount` parameter's value.
///
/// This method does the same job as `concurrentDispatch` with
/// `concurrent` set to 1. However, it is faster (as there is no overhead
/// of synchronization) and therefore preferable when only one task has to
/// be performed at once.
///
/// - Parameter next: Spawn a task with the given index. Return `nil` if all tasks have been spawn.
/// - Parameter retryCount: The number of times a task should be retried in case it fails.
/// - Parameter dispatchQueue: The DispatchQueue on which the result should be notified.
public func sequence<T>(
  spawnTask next: @escaping (Int) -> Promise<T>?,
  retryCount: Int = 2,
  on dispatchQueue: DispatchQueue? = .main
) -> Promise<()> {
  .init { seal in
    var taskCount = 0
    var currentRetryCount = 0
    
    func observer(_ result: Result<T, Error>) {
      switch result {
      case .success:
        taskCount += 1
        currentRetryCount = 0
        guard let promise = next(taskCount) else {
          seal.resolve(on: dispatchQueue)
          return
        }
        promise.finally(with: observer)
      case .failure where currentRetryCount < retryCount:
        currentRetryCount += 1
        guard let promise = next(taskCount) else {
          seal.resolve(on: dispatchQueue)
          return
        }
        promise.finally(with: observer)
      case .failure(let error):
        seal.reject(with: error, on: dispatchQueue)
      }
    }
    
    guard let promise = next(taskCount) else {
      seal.resolve(on: dispatchQueue)
      return
    }
    promise.finally(with: observer)
  }
}

public typealias Thunk<T> = () -> T

/// Execute a series of tasks in a sequence. A new task
/// is spawned once the previous one succeeds. If a task tails,
/// it can (optionally) be retried for several times, depending on the
/// `retryCount` parameter's value.
///
/// This method does the same job as `concurrentDispatch` with
/// `concurrent` set to 1. However, it is faster (as there is no overhead
/// of synchronization) and therefore preferable when only one task has to
/// be performed at once.
///
/// - Parameter promises: An ordered collection of (thunked) promises that will be executed one by one.
/// - Parameter retryCount: The number of times a task should be retried in case it fails.
/// - Parameter dispatchQueue: The DispatchQueue on which the result should be notified.
public func sequence<C: Collection, T>(
  promises: C,
  retryCount: Int = 2,
  on dispatchQueue: DispatchQueue? = .main
) -> Promise<()> where C.Element == Thunk<Promise<T>>, C.Index == Int {
  func next(_ idx: Int) -> Promise<T>? {
    guard promises.indices.contains(idx) else { return nil }
    return promises[idx]()
  }
  return sequence(spawnTask: next, retryCount: retryCount, on: dispatchQueue)
}

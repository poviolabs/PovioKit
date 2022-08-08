//
//  Sequence.swift
//  
//
//  Created by Toni K. Turk on 08/08/2022.
//

import Foundation

public func sequence<T>(
  spawnTask: @escaping (Int) -> Promise<T>?,
  retryCount: Int = 2
) -> Promise<()> {
  .init { seal in
    var taskCount = 0
    var currentRetryCount = 0
    
    func observer(_ result: Result<T, Error>) {
      switch result {
      case .success:
        taskCount += 1
        currentRetryCount = 0
        guard let promise = spawnTask(taskCount) else {
          seal.resolve()
          return
        }
        promise.finally(with: observer)
      case .failure where currentRetryCount < retryCount:
        currentRetryCount += 1
        guard let promise = spawnTask(taskCount) else {
          seal.resolve()
          return
        }
        promise.finally(with: observer)
      case .failure(let error):
        seal.reject(with: error)
      }
    }
    
    guard let promise = spawnTask(taskCount) else {
      seal.resolve()
      return
    }
    promise.finally(with: observer)
  }
}

public typealias Thunk<T> = () -> T

public func sequence<C: Collection, T>(
  promises: C,
  retryCount: Int = 2
) -> Promise<()> where C.Element == Thunk<Promise<T>>, C.Index == Int {
  func next(_ idx: Int) -> Promise<T>? {
    guard promises.indices.contains(idx) else { return nil }
    return promises[idx]()
  }
  return sequence(spawnTask: next, retryCount: retryCount)
}

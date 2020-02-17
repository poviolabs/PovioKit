//
//  Combine.swift
//  PovioKit
//
//  Created by Toni Kocjan on 02/02/2020.
//

import Foundation


/// Returns a new Promise, combining multiple `Promise`s.
///
/// Use this method when you need to combine the result of several promises of some type `T`.
///
/// - Parameter promises: A list of `Promises` that you want to combine.
/// - Returns: A Promise with the result of an array of all the values of the combined promises.
public func combine<T>(
  on dispatchQueue: DispatchQueue? = .main,
  promises: [Promise<T>]) -> Promise<[T]>
{
  Promise<[T]> { seal in
    let barrier = DispatchQueue(label: "combineQueue", attributes: .concurrent)
    for promise in promises {
      promise.observe { result in
        switch result {
        case .success:
          barrier.async(flags: .barrier) {
            if promises.allSatisfy({ $0.isFulfilled }) {
              dispatchQueue.async {
                seal.resolve(with: promises.compactMap { $0.value })
              }
            }
          }
        case .failure(let error):
          dispatchQueue.async {
            seal.reject(with: error)
          }
        }
      }
    }
  }
}

/// Returns a new Promise combineing the results of the two promises of possibly
/// different types.
///
/// Use this method to combine the results of two promises.
///
/// - Parameter p1: first Promise.
/// - Parameter p2: second Promise.
/// - Returns: A Promise with the result of given promises. If any of the promises fail
///   than the new Promise fails as well.
///
public func combine<T, U>(
  on dispatchQueue: DispatchQueue = .main,
  _ p1: Promise<T>,
  _ p2: Promise<U>) -> Promise<(T, U)>
{
  combine(on: dispatchQueue, promises: [p1.asVoid, p2.asVoid])
    .map { _ in (p1.value!, p2.value!) }
}

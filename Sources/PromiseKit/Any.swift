//
//  Any.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/08/2021.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

/// Returns a new Promise, combining multiple promises.
///
/// Use this method when you need to combine the result of several promises of type `T`,
/// where at least one has to succeed.
///
/// - Parameter promises: A collection of `Promises` that you want to combine.
/// - Returns: An array of `Optional<T>` values wrapped in a Promise.
public func any<T, C: Collection>(
  on dispatchQueue: DispatchQueue? = .main,
  promises: C
) -> Promise<[T?]> where C.Element == Promise<T> {
  guard !promises.isEmpty else {
    return .value([])
  }
  
  return .init { seal in
    let barrier = DispatchQueue(label: "combineQueue", attributes: .concurrent)
    for promise in promises {
      promise.observe { result in
        switch result {
        case .success:
          barrier.async(flags: .barrier) {
            if promises.contains(where: { $0.isFulfilled }) {
              seal.resolve(with: promises.map { $0.value }, on: dispatchQueue)
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

/// Returns a new Promise combining the results of the two promises of possibly
/// different types.
///
/// Use this method to combine the results of two promises,
/// where at least one has to succeed.
///
/// - Parameter p1: first Promise.
/// - Parameter p2: second Promise.
/// - Returns: A Promise with the result of given promises.
public func any<T, U>(
  on dispatchQueue: DispatchQueue? = .main,
  _ p1: Promise<T>,
  _ p2: Promise<U>
) -> Promise<(T, U)> {
  any(on: dispatchQueue, promises: [p1.asVoid, p2.asVoid])
    .map { _ in (p1.value!, p2.value!) }
}

/// Returns a new Promise combining the results of three promises of possibly
/// different types.
///
/// Use this method to combine the results of three promises,
/// where at least one has to succeed.
///
/// - Parameter p1: first Promise.
/// - Parameter p2: second Promise.
/// - Parameter p3: third Promise.
/// - Returns: A Promise with the result of given promises.
public func any<T, U, V>(
  on dispatchQueue: DispatchQueue? = .main,
  _ p1: Promise<T>,
  _ p2: Promise<U>,
  _ p3: Promise<V>
) -> Promise<(T, U, V)> {
  any(on: nil, promises: [p1.asVoid, p2.asVoid, p3.asVoid])
    .map(on: dispatchQueue) { _ in (p1.value!, p2.value!, p3.value!) }
}

/// Returns a new Promise combining the results of four promises of possibly
/// different types.
///
/// Use this method to combine the results of four promises,
/// where at least one has to succeed.
///
/// - Parameter p1: first Promise.
/// - Parameter p2: second Promise.
/// - Parameter p3: third Promise.
/// - Parameter p4: fourth Promise.
/// - Returns: A Promise with the result of given promises.
public func any<T, U, V, Z>(
  on dispatchQueue: DispatchQueue? = .main,
  _ p1: Promise<T>,
  _ p2: Promise<U>,
  _ p3: Promise<V>,
  _ p4: Promise<Z>
) -> Promise<(T, U, V, Z)> {
  any(on: nil, promises: [p1.asVoid, p2.asVoid, p3.asVoid, p4.asVoid])
    .map(on: dispatchQueue) { _ in (p1.value!, p2.value!, p3.value!, p4.value!) }
}

/// Returns a new Promise combining the results of four promises of possibly
/// different types.
///
/// Use this method to combine the results of five promises,
/// where at least one has to succeed.
///
/// - Parameter p1: first Promise.
/// - Parameter p2: second Promise.
/// - Parameter p3: third Promise.
/// - Parameter p4: fourth Promise.
/// - Returns: A Promise with the result of given promises.
public func any<T, U, V, Z, X>(
  on dispatchQueue: DispatchQueue? = .main,
  _ p1: Promise<T>,
  _ p2: Promise<U>,
  _ p3: Promise<V>,
  _ p4: Promise<Z>,
  _ p5: Promise<X>
) -> Promise<(T, U, V, Z, X)> {
  any(on: nil, promises: [p1.asVoid, p2.asVoid, p3.asVoid, p4.asVoid, p5.asVoid])
    .map(on: dispatchQueue) { _ in (p1.value!, p2.value!, p3.value!, p4.value!, p5.value!) }
}

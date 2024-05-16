//
//  Poll.swift
//  PovioKit
//
//  Created by Toni Kocjan on 23/09/2021.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

/// Perform polling.
///
/// This method implements a polling technique by
/// repeating request(s) while the predicate is met.
///
/// Example:
///
///     func checkStatus() -> Promise<Bool> {
///       // query the server regarding the status ...
///     }
///
///     poll(
///       repeat: checkStatus,     // repeate checking the status
///       checkAfter: .seconds(5), // ... every 5 seconds
///       while: { !$0 }           // ... while it remains `false`
///     )
///     .finally { print("Polling result: \($0)") }
///
/// - Parameter request: Provide a new request.
/// - Parameter interval: Delay between requests.
/// - Parameter predicate: Repeat requests while the predicate returns `true`.
/// - Parameter maxRetry: A maximum number of retries allowed.
/// - Parameter pollingDispatchQueue: The DispatchQueue on which the polling is performed.
/// - Parameter resolveDispatchQueue: The DispatchQueue on which the resulting promise is resolved.
///
public func poll<T>(
  repeat request: @escaping () -> Promise<T>,
  checkAfter interval: DispatchTimeInterval,
  while predicate: @escaping (T) -> Bool,
  maxRetry retry: UInt = .max,
  pollOn pollingDispatchQueue: DispatchQueue = .global(),
  resolveOn resolveDispatchQueue: DispatchQueue? = .main
) -> Promise<T> {
  poll(
    repeat: request,
    checkAfter: { _ in interval },
    while: predicate,
    maxRetry: retry,
    pollOn: pollingDispatchQueue,
    resolveOn: resolveDispatchQueue
  )
}

public protocol PollingDelay {
  var checkAfter: DispatchTimeInterval { get }
}

/// Perform polling.
///
/// This method implements a polling technique by
/// repeating request(s) while the predicate is met.
///
/// The underlying mechanism of this method is the same as for
/// `poll(request:interval:predicate:pollingDispatchQueue:resolveDispatchQueue)`.
/// The difference between the two is that in the case of this method we are actually
/// given the delay as a result of the request. For this reason we do not have to fix it
/// in advance.
///
/// Example:
///
///     struct ServerResponse: PollingDelay {
///       let status: Bool
///       let checkAfter: DispatchTimeInterval
///     }
///
///     func checkStatus() -> Promise<ServerResponse> {
///       // query the server regarding the status ...
///     }
///
///     poll(
///       repeat: checkStatus,     // repeating checking the status
///       while: { !$0.status }    // ... while it remains `false`
///     )
///     .finally { print("Polling result: \($0)") }
///
/// - Parameter request: Provide a new request.
/// - Parameter predicate: Repeat requests while the predicate returns `true`.
/// - Parameter maxRetry: A maximum number of retries allowed.
/// - Parameter pollingDispatchQueue: The DispatchQueue on which the polling is performed.
/// - Parameter resolveDispatchQueue: The DispatchQueue on which the resulting promise is resolved.
///
public func poll<T: PollingDelay>(
  repeat request: @escaping () -> Promise<T>,
  while predicate: @escaping (T) -> Bool,
  maxRetry retry: UInt = .max,
  pollOn pollingDispatchQueue: DispatchQueue = .global(),
  resolveOn resolveDispatchQueue: DispatchQueue? = .main
) -> Promise<T> {
  poll(
    repeat: request,
    checkAfter: { $0.checkAfter },
    while: predicate,
    maxRetry: retry,
    pollOn: pollingDispatchQueue,
    resolveOn: resolveDispatchQueue
  )
}

/// The underlying implementation of polling.
func poll<T>(
  repeat request: @escaping () -> Promise<T>,
  checkAfter: @escaping (T) -> DispatchTimeInterval,
  while predicate: @escaping (T) -> Bool,
  maxRetry retry: UInt,
  pollOn pollingDispatchQueue: DispatchQueue = .global(),
  resolveOn resolveDispatchQueue: DispatchQueue? = .main
) -> Promise<T> {
  precondition(retry > 0)
  return .init { seal in
    let barrier = DispatchQueue(label: "barrier", attributes: .concurrent)
    var retry = retry
    func polling() {
      let promise = request()
      barrier.async(flags: .barrier) {
        promise.finally {
          switch $0 {
          case .success(let value) where predicate(value):
            guard retry > 0 else {
              seal.reject(with: NSError(domain: "com.promise.poll", code: 999, userInfo: ["message": "Reached a maximum number of retries"]))
              return
            }
            retry -= 1
            pollingDispatchQueue.asyncAfter(deadline: .now() + checkAfter(value), execute: polling)
          case .success(let value):
            seal.resolve(with: value, on: resolveDispatchQueue)
          case .failure(let error):
            seal.reject(with: error, on: resolveDispatchQueue)
          }
        }
      }
    }
    polling()
  }
}

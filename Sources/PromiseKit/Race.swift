//
//  Race.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/08/2021.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

/// Returns a new promise that fulfills or rejects as soon as one of the promises
/// in the collection fulfills or rejects, with the result from that promise.
///
/// - Parameter promises: A collection of `Promises`.
/// - Returns: The result of the first fullfiled promise in the collection wrapped in a promise.
public func race<T, C: Collection>(
  on dispatchQueue: DispatchQueue = .main,
  promises: C
) -> Promise<T> where C.Element == Promise<T> {
  guard !promises.isEmpty else {
    return .error(NSError(domain: "com.poviokit.promisekit", code: 101, userInfo: nil))
  }
  
  return .init { seal in
    let barrier = DispatchQueue(label: "com.poviokit.promisekit.barrier", attributes: .concurrent)
    for promise in promises {
      promise.finally { result in
        switch result {
        case .success(let value):
          barrier.async(flags: .barrier) {
            seal.resolve(with: value)
          }
        case .failure(let error):
          barrier.async(flags: .barrier) {
            seal.reject(with: error, on: dispatchQueue)
          }
        }
      }
    }
  }
}

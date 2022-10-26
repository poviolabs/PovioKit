//
//  ConcurrentDispatch.swift
//  PovioKit
//
//  Created by Toni Kocjan on 23/09/2021.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

/// Concurrently execute several tasks at the same time,
/// continuing with new tasks once the previous one finishes.
///
/// You can use this method, for example, for implementing chunked
/// file uploading:
///
/// let file: Data = ...
/// let chunkSize = 1_000_000 // 1MB
///
/// func uploadChunk(_ index: Int) -> Promise<()>? {
///   let offset = index * chunkSize
///   guard offset < data.count else { return nil }
///   let chunk = data[offset..<min(offset + chunkSize, data.count)]
///   let base64 = chunk.base64EncodedString()
///   return upload(base64EncodedData: base64)
/// }
///
/// concurrentlyDispatch(
///   next: uploadChunk,
///   concurrent: 5, // concurrently upload up to 5 chunks at a time
///   retryCount: 5  // retry them for a maximum of 5 times in case they fail
/// )
/// .finally { print("Upload result: \($0)") }
///
/// In scenarios where only one concurrent task can be executed at once,
/// using `sequence` is preferable as it is much faster.
///
/// - Parameter next: Spawn a task with the given index. Return `nil` if all tasks have been spawn.
/// - Parameter concurrent: The number of concurrent tasks executing at a given time.
/// - Parameter retryCount: The number of times a task should be retried in case it fails.
/// - Parameter dispatchQueue: The DispatchQueue on which the result should be notified.
///
public func concurrentlyDispatch<T>(
  spawnTask next: @escaping (Int) -> Promise<T>?,
  concurrent: Int,
  retryCount: Int = 2,
  reserveCapacity: Int? = nil,
  preserveOrder: Bool = false,
  on dispatchQueue: DispatchQueue? = .main
) -> Promise<[T]> {
  .init { seal in
    let barrier = DispatchQueue(label: "com.poviokit.promisekit.barrier", attributes: .concurrent)
    var taskCounter = concurrent
    
    var results = [(T, Int)]()
    if let reserveCapacity {
      results.reserveCapacity(reserveCapacity)
    }
    
    var segmentIndex = concurrent
    var activePromises = [(promise: Promise<T>, retryCount: Int, segmentIndex: Int)]()
    activePromises.reserveCapacity(concurrent)
    
    for segmentIndex in 0..<concurrent {
      guard let promise = next(segmentIndex) else { break }
      activePromises.append((promise: promise, retryCount: 0, segmentIndex: segmentIndex))
      taskCounter += 1
    }
    
    func observer(_ result: Result<T, Error>, arrayIndex: Int, taskIndex: Int) {
      barrier.async(flags: .barrier) {
        let currentSegmentIndex = activePromises[arrayIndex].segmentIndex
        let alreadyRetriedCount = activePromises[arrayIndex].retryCount
        
        switch result {
        case .success(let result):
          results.append((result, taskIndex))
          guard let promise = next(segmentIndex) else {
            if activePromises.allSatisfy({ $0.promise.isFulfilled }) { // TODO: - Should we optimise by keeping a counter of how many promises have succeeded thus far?
              if preserveOrder {
                results.sort { $0.1 < $1.1 }
              }
              seal.resolve(
                with: results.map { $0.0 },
                on: dispatchQueue
              )
            }
            return
          }
          promise.finally { observer($0, arrayIndex: arrayIndex, taskIndex: taskCounter) }
          taskCounter += 1
          activePromises[arrayIndex] = (
            promise: promise,
            retryCount: 0,
            segmentIndex: segmentIndex
          )
          segmentIndex += 1
        case .failure where alreadyRetriedCount < retryCount:
          let promise = next(currentSegmentIndex)!
          promise.finally { observer($0, arrayIndex: arrayIndex, taskIndex: taskIndex) }
          activePromises[arrayIndex] = (
            promise: promise,
            retryCount: alreadyRetriedCount + 1,
            segmentIndex: currentSegmentIndex
          )
        case .failure(let error):
          activePromises.forEach { $0.promise.reject(with: error) }
          seal.reject(with: error, on: dispatchQueue)
        }
      }
    }
    
    activePromises.enumerated().forEach { (arrayIndex, tuple) in
      tuple.promise.finally {
        observer($0, arrayIndex: arrayIndex, taskIndex: arrayIndex)
      }
    }
  }
}

public func concurrentlyDispatch<T, C>(
  workItems: C,
  concurrent: Int,
  retryCount: Int = 2,
  preserveOrder: Bool = false,
  on dispatchQueue: DispatchQueue? = .main
) -> Promise<[T]> where C: Collection, C.Element == () -> Promise<T>, C.Index == Int {
  concurrentlyDispatch(
    spawnTask: { (workItems.indices.contains($0) ? workItems[$0] : nil)?() }, 
    concurrent: concurrent, 
    retryCount: retryCount, 
    reserveCapacity: workItems.count, 
    preserveOrder: preserveOrder, 
    on: dispatchQueue
  )
}

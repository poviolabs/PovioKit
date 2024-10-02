//
//  Array+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/10/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

extension Array {
  /// Splits the array into chunks of a specified size.
  ///
  /// - Parameter size: The size of each chunk. Each chunk will contain up to `size` elements.
  /// - Returns: An array of arrays, where each inner array is a chunk of the original array.
  ///
  /// - Note: If the array's size is not a perfect multiple of `size`, the last chunk will contain the remaining elements.
  ///
  /// ## Example
  /// ```
  /// let array = [1, 2, 3, 4, 5, 6, 7]
  /// let chunks = array.chunked(into: 3)
  /// // chunks is [[1, 2, 3], [4, 5, 6], [7]]
  /// ```
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
  
  /// Updates the element at the specified index with a new value.
  ///
  /// - Parameters:
  ///   - item: The new value to set at the specified index.
  ///   - index: The index of the element to update.
  /// - Returns: A boolean value indicating whether the update was successful. Returns `true` if the index is valid and the update was performed; otherwise, returns `false`.
  ///
  /// ## Example
  /// ```
  /// var array = [1, 2, 3, 4]
  /// let success = array.update(10, at: 2)
  /// // array is now [1, 2, 10, 4]
  /// // success is true
  ///
  /// let failure = array.update(10, at: 10)
  /// // array remains [1, 2, 10, 4]
  /// // failure is false
  /// ```
  @discardableResult
  mutating func update(_ item: Element, at index: Int) -> Bool {
    guard indices.contains(index) else { return false }
    self[index] = item
    return true
  }
}

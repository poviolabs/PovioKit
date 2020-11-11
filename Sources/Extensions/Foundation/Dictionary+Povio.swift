//
//  Dictionary+Povio.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import Foundation

public extension Dictionary {
  /// Make a union on two dictionaries.
  /// ```
  /// let dictionaryA = [1: "One", 2: "Two"]
  /// let dictionaryB = [3: "Three"]
  /// let unionDictionary = dictionaryA.union(dictionaryB)
  /// print(unionDictionary) // [1: "One", 2: "Two", 3: "Three"]
  /// ```
  func union(_ dictionary: Dictionary) -> Dictionary {
    reduce(dictionary) { result, keyValue in
      var result = result
      result[keyValue.0] = keyValue.1
      return result
    }
  }
}

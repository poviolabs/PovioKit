//
//  Dictionary+Povio.swift
//  PovioKit
//
//  Created by Borut Tomazin on 21/09/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension Dictionary {
  /// Make union from `Self` and given `dictionary`
  /// Examples:
  /// ```
  /// print([1: "One", 2: "Two"].union([3: "Three", 4: "Four"]) // result: [1: "One", 2: "Two", 3: "Three", 4: "Four"]
  /// print([1: "One", 2: "Two"].union([2: "Two"]) // result: [1: "One", 2: "Two"]
  /// ```
  func union(_ dictionary: Dictionary) -> Dictionary {
    reduce(dictionary) { result, keyValue in
      var result = result
      result[keyValue.0] = keyValue.1
      return result
    }
  }
}

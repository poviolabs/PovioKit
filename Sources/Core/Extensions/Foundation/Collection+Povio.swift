//
//  Collection+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {
  /// Returns the element at the specified `index` if it is within bounds, otherwise `nil`.
  subscript (safe index: Index) -> Iterator.Element? {
    (startIndex <= index && index < endIndex) ? self[index] : nil
  }
}

public extension Collection {
  /// Conditional element count - https://github.com/apple/swift-evolution/blob/master/proposals/0220-count-where.md
  func count(where clause: (Element) -> Bool) -> Int {
    lazy.filter(clause).count
  }
}

//
//  Collection+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
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

public extension Collection {
  /// Groups collection elements based on dateComponents returning a dictionary
  func grouped(
    extractDate: (Element) -> Date,
    by dateComponents: Set<Calendar.Component> = [.year, .month, .day],
    calendar: Calendar = Calendar.current
  ) -> [Date: [Element]] {
    .init(
      grouping: self,
      by: {
        let components = calendar.dateComponents(dateComponents, from: extractDate($0))
        let date = calendar.date(from: components) ?? Date()
        return date
      }
    )
  }
}

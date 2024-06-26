//
//  Collection+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public extension Collection {
  /// Returns the element at the specified `index` if it is within bounds, otherwise `nil`.
  subscript (safe index: Index) -> Element? {
    if startIndex <= index && index < endIndex { self[index] } else { nil }
  }
}

public extension Collection {
  /// Conditional element count - https://forums.swift.org/t/refresh-review-se-0220-count-where/66235/4
  @inlinable
  func count(
    where predicate: (Element) throws -> Bool
  ) rethrows -> Int {
    try reduce(0) { n, element in
      if try predicate(element) { 
        n + 1 
      } else { 
        n 
      }
    }
  }
  
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

public extension MutableCollection {
  mutating func mutateEach(_ mutator: (inout Element) throws -> Void) rethrows {
    var idx = startIndex
    while idx != endIndex {
      try mutator(&self[idx])
      formIndex(after: &idx)
    }
  }
}

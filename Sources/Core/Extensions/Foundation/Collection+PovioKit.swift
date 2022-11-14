//
//  Collection+PovioKit.swift
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

public extension Collection where Element: Dated {
  /// Groups dated collection elements returning a dictionary
  func grouped(by dateComponents: Set<Calendar.Component> = [.year, .month, .day],
               calendar: Calendar = Calendar.current) -> [Date: [Element]] {
    let initial: [Date: [Element]] = [:]
    let groupedByDateComponents = reduce(into: initial) { acc, cur in
      let components = calendar.dateComponents(dateComponents, from: cur.date)
      let date = calendar.date(from: components) ?? Date()
      let existing = acc[date] ?? []
      acc[date] = existing + [cur]
    }
    
    return groupedByDateComponents
  }
}

//
//  Date+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/05/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public extension Date {
  var isToday: Bool { calendar.isDateInToday(self) }
  var isYesterday: Bool { calendar.isDateInYesterday(self) }
  var isInFuture: Bool { self > Date() }
  
  /// Returns first day of the week
  var startOfWeek: Date? {
    let components: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear, .hour, .minute, .second, .nanosecond]
    return calendar.date(from: calendar.dateComponents(components, from: self))
  }
  
  /// Returns last day of the week
  var endOfWeek: Date? {
    guard let startOfWeek = Date().startOfWeek else { return nil }
    return calendar.date(byAdding: .day, value: 6, to: startOfWeek)
  }
}

// MARK: - Private Methods
private extension Date {
  var calendar: Calendar {
    Calendar.autoupdatingCurrent
  }
}

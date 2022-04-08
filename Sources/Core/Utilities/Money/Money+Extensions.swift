//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/07/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}

extension Int {
  var double: Double {
    Double(self)
  }
}

extension Double {
  /**
   Formats the Double value as a currency string using the provided currencyCode.
   - Note: We were using the explanation found [here](https://www.swiftbysundell.com/articles/formatting-numbers-in-swift/#domain-specific-numbers)
   and [here](https://stackoverflow.com/a/34134632) as a starting point for the implementation
   - Parameter formatter: NumberFormatter instance
   - Parameter numberStyle: NumberFormatter.Style number representation for formatting
   - Parameter currencyCode: ISO code of the currency (eg. "USD")
   - Parameter precision: The number of decimal places to represent value
   - Parameter locale: Locale object used for formatting. `Locale.current` is used if other value is not provided
   - Returns: The string value of the formatted currency Double value
   */
  func format(formatter: NumberFormatter = NumberFormatter(),
              numberStyle: NumberFormatter.Style = .currency,
              currencyCode: String,
              precision: Int,
              locale: Locale = Locale.current) -> String? {
    let currencyFormatter = formatter
    currencyFormatter.numberStyle = numberStyle
    currencyFormatter.currencyCode = currencyCode
    currencyFormatter.maximumFractionDigits = precision
    currencyFormatter.locale = locale
    return currencyFormatter.string(from: self as NSNumber)
  }
}

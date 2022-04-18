//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/05/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

public struct Defaults {
  public var precision = 2
  public var currency = Currency.usd
  public var locale = Locale.current
}

// NOTE: - Not thread safe! Previous instances won't be affected.
public var defaults = Defaults()

public struct Money: Hashable {
  public typealias Cents = Int
  
  /// Amount in minor currency units (eg. cents)
  public var amount: Cents
  /// ``Currency`` type that is containing the ISO code (eg. "USD") and symbol of the currency (eg. "$")
  public var currency: Currency
  /// The identifier for the Locale object that we use for the output formatting (eg. "en_US")
  public var localeIdentifier: String
  /// The number of decimal places to represent value
  public var precision: Int
  
  /**
   Initializes a new Money item with the provided amount and currency
   
   `localeIdentifier` and `precision` are not mandatory and we will use default values if not provided:
   - `localeIdentifier` default value is read from `Locale.current.identifier`
   - `precision` default value is 2, stored in `MoneyConstants.defaultPrecision`
   - Parameter cents: Amount value in minor currency units (eg. cents)
   - Parameter currency: ``Currency`` enum value of the supported currencies
   - Parameter localeIdentifier: Identifier for the Locale object that we use for the output formatting (eg. "en_US")
   - Parameter precision: The number of decimal places to represent value
   */
  init(
    amount: Cents,
    currency: Currency = defaults.currency,
    localeIdentifier: String = defaults.locale.identifier,
    precision: Int = defaults.precision
  ) {
    self.amount = amount
    self.currency = currency
    self.localeIdentifier = localeIdentifier
    self.precision = precision
  }
}

extension Money: Equatable, Comparable {
  public static func ==(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount == rhs.amount && lhs.currency == rhs.currency
  }

  public static func <(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount < rhs.amount && lhs.currency == rhs.currency
  }

  public static func >(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount > rhs.amount && lhs.currency == rhs.currency
  }

  public static func <=(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount <= rhs.amount && lhs.currency == rhs.currency
  }

  public static func >=(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount >= rhs.amount && lhs.currency == rhs.currency
  }
}

// MARK: - Public Methods - Getters
public extension Money {
  /**
   Convert amount value (representing minor currency units) to the unit value based on the current precision
   ```
   // Example:
   // This returns 10.545
   Money(amount: 10545, currency: .usd, precision: 3).unitValue
   ```
   */
  var unitValue: Double {
    Double(amount) / pow(10, Double(precision))
  }
  
  /**
   Return unit value formatted with currently set locale
   ```
   // Example:
   // This returns $1,234.57
   Money(amount: 123457, currency: .usd, localeIdentifier: "en_US").formatted
   ```
   */
  var formatted: String? {
    unitValue.format(currencyCode: currency.code, precision: precision, locale: locale)
  }
  
  /// Locale object from the current _localeIdentifier_
  var locale: Locale {
    Locale(identifier: localeIdentifier)
  }
  
  /// Return a new instance with precision trimed down to the safest possible scale.
  ///
  ///     let m = Money(amount: 99250, precision: 4)
  ///     let trimed = m.trimedPrecision()
  ///     XCAssertEqual(trimed.amount, 9925)
  ///     XCAssertEqual(trimed.precision, 3)
  func trimedPrecision() -> Self {
    var res = self
    res.trimPrecision()
    return res
  }
  
  /// Trim the instance down to the safest possible scale.
  ///
  ///     let m = Money(amount: 99250, precision: 4)
  ///     let trimed = m.trimedPrecision()
  ///     XCAssertEqual(trimed.amount, 9925)
  ///     XCAssertEqual(trimed.precision, 3)
  mutating func trimPrecision() {
    while amount % 10 == 0 {
      amount /= 10
      precision -= 1
    }
  }
}

// MARK: - Public Methods - Testing
public extension Money {
  var isPositive: Bool {
    amount >= .zero
  }
  
  var isNegative: Bool {
    amount < .zero
  }
  
  var isZero: Bool {
    amount == .zero
  }
}

// MARK: - Codable
extension Money: Codable {
  private enum CodingKeys: CodingKey {
    case cents, currency, localeIdentifier, precision
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    amount = try values.decode(Cents.self, forKey: .cents)
    currency = try values.decode(Currency.self, forKey: .currency)
    localeIdentifier = try values.decode(String.self, forKey: .localeIdentifier)
    precision = try values.decode(Int.self, forKey: .precision)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(amount, forKey: .cents)
    try container.encode(currency, forKey: .currency)
    try container.encode(localeIdentifier, forKey: .localeIdentifier)
    try container.encode(precision, forKey: .precision)
  }
}

// MARK: - ExpressibleByIntegerLiteral, CustomStringConvertible
extension Money: ExpressibleByIntegerLiteral, CustomStringConvertible {
  public init(integerLiteral value: Cents) {
    self.amount = value
    self.currency = defaults.currency
    self.localeIdentifier = defaults.locale.identifier
    self.precision = defaults.precision
  }
  
  public var description: String {
    return formatted ?? "\(amount) \(currency.symbol)"
  }
}

// MARK: - Math operators

public func + (_ lhs: Money, _ rhs: Money) -> Money {
  precondition(lhs.currency == rhs.currency)
  var lhs = lhs
  var rhs = rhs
  alignToSamePrecision(m1: &lhs, m2: &rhs)
  return .init(
    amount: lhs.amount + rhs.amount,
    currency: lhs.currency,
    localeIdentifier: lhs.localeIdentifier,
    precision: lhs.precision
  )
}

public func - (_ lhs: Money, _ rhs: Money) -> Money {
  precondition(lhs.currency == rhs.currency)
  var lhs = lhs
  var rhs = rhs
  alignToSamePrecision(m1: &lhs, m2: &rhs)
  return .init(
    amount: lhs.amount - rhs.amount,
    currency: lhs.currency,
    localeIdentifier: lhs.localeIdentifier,
    precision: lhs.precision)
}

public func * (_ lhs: Money, _ rhs: Money) -> Money {
  precondition(lhs.currency == rhs.currency)
  return .init(
    amount: lhs.amount * rhs.amount,
    currency: lhs.currency,
    localeIdentifier: lhs.localeIdentifier,
    precision: lhs.precision + rhs.precision)
}

// NOTE: - We do not support division, use multiplication instead!

/// - Parameter rhs: The amount of cents to be added. It is converted to `Money`:  Money(amount: rhs, currency: lhs.currency, precision: 2)
public func + (lhs: Money, rhs: Money.Cents) -> Money {
  let rhs = Money(amount: rhs, currency: lhs.currency, localeIdentifier: lhs.localeIdentifier, precision: 2)
  return lhs + rhs
}
  
/// - Parameter lhs: The amount of cents to be added. It is converted to `Money`:  Money(amount: lhs, currency: rhs.currency, precision: 2)
public func + (lhs: Money.Cents, rhs: Money) -> Money {
  let lhs = Money(amount: lhs, currency: rhs.currency, localeIdentifier: rhs.localeIdentifier, precision: 2)
  return lhs + rhs
}

/// - Parameter rhs: The amount of cents to be added. It is converted to `Money`:  Money(amount: rhs, currency: lhs.currency, precision: 2)
public func - (lhs: Money, rhs: Money.Cents) -> Money {
  let rhs = Money(amount: rhs, currency: lhs.currency, localeIdentifier: lhs.localeIdentifier, precision: 2)
  return lhs - rhs
}
  
/// - Parameter lhs: The amount of cents to be added. It is converted to `Money`:  Money(amount: lhs, currency: rhs.currency, precision: 2)
public func - (lhs: Money.Cents, rhs: Money) -> Money {
  let lhs = Money(amount: lhs, currency: rhs.currency, localeIdentifier: rhs.localeIdentifier, precision: 2)
  return lhs - rhs
}

/// - Parameter rhs: An integer multiplier.
public func * (_ lhs: Money, _ rhs: Int) -> Money {
  var res = lhs
  res.amount *= rhs
  return res
}
  
/// - Parameter rhs: An integer multiplier.
public func * (_ lhs: Int, _ rhs: Money) -> Money {
  var res = rhs
  res.amount *= lhs
  return res
}

///

fileprivate func alignToSamePrecision(m1: inout Money, m2: inout Money) {
  if m1.precision > m2.precision {
    m2.amount    = m2.amount * Money.Cents(pow(10, Double(m1.precision - m2.precision)))
    m2.precision = m1.precision
  } else if m1.precision < m2.precision {
    m1.amount    = m1.amount * Money.Cents(pow(10, Double(m2.precision - m1.precision)))
    m1.precision = m2.precision
  }
}

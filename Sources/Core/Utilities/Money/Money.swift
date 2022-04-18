//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/05/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

public struct Money {
  public typealias Cents = UInt
  
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
    cents: UInt,
    currency: Currency,
    localeIdentifier: String = Locale.current.identifier,
    precision: Int = Constants.defaultPrecision
  ) {
    self.amount = cents
    self.currency = currency
    self.localeIdentifier = localeIdentifier
    self.precision = precision
  }
}

public extension Money {
  enum Constants {
    static let defaultPrecision: Int = 2
  }
  
  enum Error {
    case currencyNotSame
    
    var description: String {
      switch self {
      case .currencyNotSame:
        return "Currencies must be the same!"
      }
    }
  }
}

extension Money: Equatable, Comparable, Hashable {
  public static func ==(lhs: Money, rhs: Money) -> Bool {
    return lhs.cents == rhs.cents && lhs.currency.code == rhs.currency.code
  }

  public static func <(lhs: Money, rhs: Money) -> Bool {
    return lhs.cents < rhs.cents && lhs.currency.code == rhs.currency.code
  }

  public static func >(lhs: Money, rhs: Money) -> Bool {
    return lhs.cents > rhs.cents && lhs.currency.code == rhs.currency.code
  }

  public static func <=(lhs: Money, rhs: Money) -> Bool {
    return lhs.cents <= rhs.cents && lhs.currency.code == rhs.currency.code
  }

  public static func >=(lhs: Money, rhs: Money) -> Bool {
    return lhs.cents >= rhs.cents && lhs.currency.code == rhs.currency.code
  }
  
  public static func + (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.currency == rhs.currency)
    return .init(cents: lhs.cents + rhs.cents, currency: lhs.currency, precision: 2)
  }
  
  public static func - (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.currency == rhs.currency)
    return .init(cents: lhs.cents - rhs.cents, currency: lhs.currency, precision: 2)
  }
  
  public static func * (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.currency == rhs.currency)
    return .init(cents: lhs.cents * rhs.cents, currency: lhs.currency, precision: 2)
  }
  
  public static func / (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.currency == rhs.currency)
    let amount = UInt((Double(lhs.cents) / Double(rhs.cents)).rounded(.toNearestOrAwayFromZero))
    return .init(cents: amount, currency: lhs.currency, precision: 2)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(cents)
    hasher.combine(currency.code)
    hasher.combine(precision)
  }
}

extension Money: Codable {
  private enum CodingKeys: CodingKey {
    case cents, currency, localeIdentifier, precision
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    amount = try values.decode(UInt.self, forKey: .cents)
    currency = try values.decode(Currency.self, forKey: .currency)
    localeIdentifier = try values.decode(String.self, forKey: .localeIdentifier)
    precision = try values.decode(Int.self, forKey: .precision)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(cents, forKey: .cents)
    try container.encode(currency, forKey: .currency)
    try container.encode(localeIdentifier, forKey: .localeIdentifier)
    try container.encode(precision, forKey: .precision)
  }
}

extension Money: ExpressibleByIntegerLiteral, CustomStringConvertible {
   public init(integerLiteral value: UInt) {
     self.amount = value
     self.currency = .usd
     self.localeIdentifier = Locale.current.identifier
     self.precision = Constants.defaultPrecision
  }

  public var description: String {
    return formatted ?? "\(cents) \(currency.symbol)"
  }
}

// MARK: - Public Methods - Getters
public extension Money {
  /**
   Convert amount value (representing minor currency units) to the unit value based on the current precision
   ```
   // Example:
   // This returns 10.545
   Money(cents: 10545, currency: .usd, precision: 3).unitValue
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
   Money(cents: 123457, currency: .usd, localeIdentifier: "en_US").formatted
   ```
   */
  var formatted: String? {
    unitValue.format(currencyCode: currency.code, precision: precision, locale: locale)
  }
  
  /// Locale object from the current _localeIdentifier_
  var locale: Locale {
    Locale(identifier: localeIdentifier)
  }
  
  var cents: Cents {
    Cents(Double(amount) * pow(10, Double(-precision + 2)))
  }
}

// MARK: - Public Methods - Manipulation
//public extension Money {
//  /**
//   Multiply the current amount with the multiplier value.
//   - Note: _currency_, _localeIdentifier_ and _precision_ are used from the original Money item.
//   - Parameter multiplier: Double value that we will multiply the amount with
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: **new** Money item that contains multiplication result as an amount.
//   */
//  func multiply(
//    _ multiplier: Double,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Money {
//    let cents = calculateMultiply(amount: cents.double, multiplier: multiplier, roundingMode: roundingMode)
//    return Money(cents: cents,
//                 currency: currency,
//                 localeIdentifier: localeIdentifier,
//                 precision: precision)
//  }
//
//  /**
//   Divide the amount of the current Money item with the divisor value.
//   - Note: _currency_, _localeIdentifier_ and _precision_ are used from the original Money item.
//   - Parameter divisor: Double value that we will divide the amount with
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: **new** Money item that contains division result as an amount.
//   */
//  func divide(
//    _ divisor: Double,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Money {
//    let cents = calculateDivide(amount: cents.double, divisor: divisor, roundingMode: roundingMode)
//    return Money(cents: cents,
//                 currency: currency,
//                 localeIdentifier: localeIdentifier,
//                 precision: precision)
//  }
//
//  /**
//   Calculate the percentage value for the amount of the current Money item.
//   - Note: The percentage value must be in the range from 1 to 100. If the passed value is not in this range we will clamp it to an acceptable value.
//   - Parameter percentage: Double percent value that we will apply to the amount
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: **new** Money item that contains percent of the current amount.
//   */
//  func percentage(
//    _ percentage: Double,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Money {
//    let cents = calculatePercentageAmount(amount: cents.double, percentage: percentage, roundingMode: roundingMode)
//    return Money(cents: cents,
//                 currency: currency,
//                 localeIdentifier: localeIdentifier,
//                 precision: precision)
//  }
//
//  /**
//   Create new Money object with the provided value for the _localeIdentifier_ parameter
//   - Note: _amount_, _currency_ and _precision_ are used from the original Money item.
//   - Parameter locale: String value for the _localeIdentifier_ parameter
//   - Returns: **new** Money item with the new _localeIdentifier_
//   */
//  func setLocaleIdentifier(_ locale: String) -> Money {
//    Money(cents: cents,
//          currency: currency,
//          localeIdentifier: locale,
//          precision: precision)
//  }
//}

// MARK: - Public Methods - Muttating Manipulations
//public extension Money {
//  /**
//   Multiply the amount of the current Money item with the multiplier value.
//   - Parameter multiplier: Double value that we will multiply the amount with
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   */
//  mutating func multiply(_ multiplier: Double,
//                         roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
//    self.cents = calculateMultiply(amount: cents.double, multiplier: multiplier, roundingMode: roundingMode)
//  }
//
//  /**
//   Divide the amount of the current Money item with the divisor value.
//   - Parameter divisor: Double value that we will divide the amount with
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   */
//  mutating func divide(_ divisor: Double,
//                       roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
//    self.cents = calculateDivide(amount: cents.double, divisor: divisor, roundingMode: roundingMode)
//  }
//
//  /**
//   Calculate percentage value for the amount of the current Money item.
//   - Note: The percentage value must be in the range from 1 to 100. If the passed value is not in this range we will clamp it to an acceptable value.
//   - Parameter percentage: Double percent value that we will apply to the amount
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   */
//  mutating func percentage(_ percentage: Double,
//                           roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
//    self.cents = calculatePercentageAmount(amount: cents.double, percentage: percentage, roundingMode: roundingMode)
//  }
//
//  /**
//   Sets the new value for the _localeIdentifier_ parameter
//   - Parameter locale: String value for the _localeIdentifier_ parameter
//   */
//  mutating func setLocaleIdentifier(_ locale: String) {
//    self.localeIdentifier = locale
//  }
//}

// MARK: - Public Methods - Testing
public extension Money {
  var isPositive: Bool {
    amount >= .zero
  }
  
  var isNegative: Bool {
    amount < .zero
  }
  
  var isZero: Bool {
    cents == .zero
  }
  
//  /// Check if two Money items has the same amount
//  /// - Note: Currency and other parameters are ignored
//  func hasSameAmount(_ other: Money) -> Bool {
//    self.cents == other.cents
//  }
//
//  /// Check if two Money items has the same currency
//  /// - Note: Amount and other parameters are ignored
//  func hasSameCurrency(_ other: Money) -> Bool {
//    self.currency.code == other.currency.code
//  }
}

// MARK: - Private Methods - Static
//private extension Money {
//  /**
//   Normalize precision for the multiple Money objects.
//
//   We will get maximum precision value in the array of Money items and use it to convert other items to that level
//   - Note: If getting the highest value fails for some reason, we will use `MoneyConstants.defaultPrecision`
//   - Parameter objects: Array of the Money objects that we need to get to the same level of precision
//   - Returns: An array of the Money objects in the same order as provided, but with applied calculated precision on each element
//   */
//  static func normalizePrecision(_ objects: [Money]) -> [Money] {
//    let highestPrecision = objects.max { $0.precision < $1.precision }?.precision ?? Constants.defaultPrecision
//    return objects.map {
//      $0.precision == highestPrecision ? $0 : $0.convertPrecision(highestPrecision)
//    }
//  }
//
//  /**
//   Convert unit value to cents with some precision
//
//   - Parameter unitValue: Double amount of the value we want to convert
//   - Parameter precision: The number of decimal places to represent value
//   - Returns: Double with calculated precision
//   */
//  static func convertToCents(
//    _ unitValue: Double,
//    precision: Int,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Int {
//    Int(unitValue * pow(10, Double(precision)).rounded(roundingMode))
//  }
//}

// MARK: - Private Methods - Utils
//private extension Money {
//  /**
//   Round Double amount value to the Int with provided rounding mode
//
//   We will round the double value and convert it to Int
//   - Parameter amount: Double value amount that we want to round
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: Int value of the provided amount
//   */
//  func round(
//    _ amount: Double,
//    _ roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Int {
//    return Int(amount.rounded(roundingMode))
//  }
//
//  /**
//   Convert precision of the Money object to the provided new precision
//
//   We will calculate difference of the new precision and current one and apply it to the amount of the current Money object.
//   After that, we need to round the new amount and create new Money object with it.
//   - Note: _currency_ and _localeIdentifier_ are used from the original Money item.
//   - Parameter newPrecision: Int value of the new precision
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: **new** Money item with the provided precision and calculated amount
//   */
//  func convertPrecision(
//    _ newPrecision: Int,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Money {
////    let newAmount = cents.double * pow(10, Double(newPrecision - precision))
////    let rounded = round(newAmount, roundingMode)
////    return Money(cents: rounded,
////                 currency: currency,
////                 localeIdentifier: localeIdentifier,
////                 precision: newPrecision)
//    fatalError()
//  }
//
//  /**
//   Calculate multiplication of the provided amount value and the multiplier value.
//   - Parameter amount: Double value of the amount that we calculate multiplication
//   - Parameter multiplier: Double value that we will multiply the amount with
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: Int value of the multiplication result
//   */
//  func calculateMultiply(
//    amount: Double,
//    multiplier: Double,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Int {
////    let newAmount = amount * multiplier
////    return round(newAmount, roundingMode)
//    fatalError()
//  }
//
//  /**
//   Calculate division of the provided amount value and the divisor value.
//   - Parameter amount: Double value of the amount that we calculate division
//   - Parameter divisor: Double value that we will divide the amount with
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: Int value of the division result
//   */
//  func calculateDivide(
//    amount: Double,
//    divisor: Double,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Int {
////    let newAmount = amount / divisor
////    return round(newAmount, roundingMode)
//    fatalError()
//  }
//
//  /**
//   Calculate percentage of the amount value
//   - Note: The percentage value must be in the range from 1 to 100. If the passed value is not in this range we will clamp it to an acceptable value.
//   - Parameter amount: Double value of the amount that we calculate percentage
//   - Parameter percentage: Double percent value that we will apply to the amount
//   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
//   - Returns: Int value of the amount percentage
//   */
//  func calculatePercentageAmount(
//    amount: Double,
//    percentage: Double,
//    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
//  ) -> Int {
////    let clampedPercentage = percentage.clamped(to: 0...100)
////    let newAmount = amount * (clampedPercentage / 100.0)
////    return round(newAmount, roundingMode)
//    fatalError()
//  }
//}

//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/05/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation

enum MoneyConstants {
  static let defaultPrecision: Int = 2
}

public enum MoneyError: Error {
  case currencyNotSame
}

public struct Money {
  private(set) var amount: Int /// Amount in minor currency units (eg. cents)
  private(set) var currency: String /// ISO code of the currency (eg. "USD")
  private(set) var localeIdentifier: String /// The identifier for the Locale object that we use for the output formatting (eg. "en_US")
  private(set) var precision: Int = MoneyConstants.defaultPrecision /// The number of decimal places to represent value
  
  /**
   Initializes a new Money item with the provided amount and currency
   
   `localeIdentifier` and `precision` are not mandatory and we will use default values if not provided:
   - `localeIdentifier` default value is read from `Locale.current.identifier`
   - `precision` default value is 2, stored in `MoneyConstants.defaultPrecision`
   - Parameter amount: Amount value in minor currency units (eg. cents)
   - Parameter currency: ISO code of the currency (eg. "USD")
   - Parameter localeIdentifier: Identifier for the Locale object that we use for the output formatting (eg. "en_US")
   - Parameter precision: The number of decimal places to represent value
   */
  init(amount: Int,
       currency: String,
       localeIdentifier: String = Locale.current.identifier,
       precision: Int = MoneyConstants.defaultPrecision) {
    self.amount = amount
    self.currency = currency.uppercased()
    self.localeIdentifier = localeIdentifier
    self.precision = precision
  }
}

// MARK: - Public Methods - Getters
public extension Money {
  /**
   Convert amount value (representing minor currency units) to the unit value based on the current precision
   ```
   // Example:
   // This returns 10.545
   Money(amount: 10545, currency: "USD", precision: 3).unitValue
   ```
   */
  var unitValue: Double {
    amount.double / pow(10, precision.double)
  }
  
  /**
   Return unit value formatted with currently set locale
   ```
   // Example:
   // This returns $1,234.57
   Money(amount: 123457, currency: "USD", localeIdentifier: "en_US").unitValue
   ```
   */
  var formatted: String? {
    unitValue.format(currencyCode: currency, precision: precision, locale: locale)
  }
  
  /// Locale object from the current _localeIdentifier_
  var locale: Locale {
    Locale(identifier: localeIdentifier)
  }
}

// MARK: - Public Methods - Manipulation
public extension Money {
  /**
   Add the amount from addend Money to the current amount
   
   First, we need to normalize precisions from two Money items to get them to the same level.
   After that, we can add one amount to another and set this value to be the new amount for the new Money object.
   - Attention: **.none** is returned if the currency codes are not the same
   - Note: _Currency_ and _localeIdentifier_ are used from the original Money item.
   - Parameter addend: Money item that we want to add to the current Money item
   - Returns: **new** Money item that contains added amount and normalized precision.
   */
  func add(_ addend: Money) -> Money? {
    guard addend.currency == currency else {
      return .none
    }
    let normalizedPrecision = Money.normalizePrecision([self, addend])
    let newAmount = normalizedPrecision[0].amount + normalizedPrecision[1].amount
    return Money(amount: newAmount,
                 currency: currency,
                 localeIdentifier: localeIdentifier,
                 precision: normalizedPrecision[0].precision)
  }
  
  /**
   Subtract the subtrahend Money from the current amount
   
   First, we need to normalize precisions from two Money items to get them to the same level of precision.
   After that, we can subtract one amount from another and set this value to be the new amount for the new Money object.
   - Attention: **.none** is returned if the currency codes are not the same
   - Note: _currency_ and _localeIdentifier_ are used from the original Money item.
   - Parameter subtrahend: Money item with amount that we want to subtrahend from the current Money item
   - Returns: **new** Money item that contains subtracted amount and normalized precision.
   */
  func subtract(_ subtrahend: Money) -> Money? {
    guard subtrahend.currency == currency else {
      return .none
    }
    let normalizedPrecision = Money.normalizePrecision([self, subtrahend])
    let newAmount = normalizedPrecision[0].amount - normalizedPrecision[1].amount
    return Money(amount: newAmount,
                 currency: currency,
                 localeIdentifier: localeIdentifier,
                 precision: normalizedPrecision[0].precision)
  }
  
  /**
   Multiply the current amount with the multiplier value.
   - Note: _currency_, _localeIdentifier_ and _precision_ are used from the original Money item.
   - Parameter multiplier: Double value that we will multiply the amount with
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: **new** Money item that contains multiplication result as an amount.
   */
  func multiply(
    _ multiplier: Double,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Money {
    let cents = calculateMultiply(amount: amount.double, multiplier: multiplier, roundingMode: roundingMode)
    return Money(amount: cents,
                 currency: currency,
                 localeIdentifier: localeIdentifier,
                 precision: precision)
  }
  
  /**
   Divide the amount of the current Money item with the divisor value.
   - Note: _currency_, _localeIdentifier_ and _precision_ are used from the original Money item.
   - Parameter divisor: Double value that we will divide the amount with
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: **new** Money item that contains division result as an amount.
   */
  func divide(
    _ divisor: Double,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Money {
    let cents = calculateDivide(amount: amount.double, divisor: divisor, roundingMode: roundingMode)
    return Money(amount: cents,
                 currency: currency,
                 localeIdentifier: localeIdentifier,
                 precision: precision)
  }
  
  /**
   Calculate the percentage value for the amount of the current Money item.
   - Note: The percentage value must be in the range from 1 to 100. If the passed value is not in this range we will clamp it to an acceptable value.
   - Parameter percentage: Double percent value that we will apply to the amount
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: **new** Money item that contains percent of the current amount.
   */
  func percentage(
    _ percentage: Double,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Money {
    let cents = calculatePercentageAmount(amount: amount.double, percentage: percentage, roundingMode: roundingMode)
    return Money(amount: cents,
                 currency: currency,
                 localeIdentifier: localeIdentifier,
                 precision: precision)
  }
  
  /**
   Create new Money object with the provided value for the _localeIdentifier_ parameter
   - Note: _amount_, _currency_ and _precision_ are used from the original Money item.
   - Parameter locale: String value for the _localeIdentifier_ parameter
   - Returns: **new** Money item with the new _localeIdentifier_
   */
  func setLocaleIdentifier(_ locale: String) -> Money {
    Money(amount: amount,
          currency: currency,
          localeIdentifier: locale,
          precision: precision)
  }
}

// MARK: - Public Methods - Muttating Manipulations
public extension Money {
  /**
   Add the new amount to the current Money item.
   - Parameter amount: Int value of the amount that we want to add to the current Money item
   */
  mutating func add(_ amount: Int) {
    self.amount += amount
  }
  
  /**
   Subtract the amount from the current Money item.
   - Parameter amount: Amount that we want to subtrahend from the current Money item
   */
  mutating func subtract(_ amount: Int) {
    self.amount -= amount
  }
  
  /**
   Multiply the amount of the current Money item with the multiplier value.
   - Parameter multiplier: Double value that we will multiply the amount with
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   */
  mutating func multiply(_ multiplier: Double,
                         roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
    self.amount = calculateMultiply(amount: amount.double, multiplier: multiplier, roundingMode: roundingMode)
  }
  
  /**
   Divide the amount of the current Money item with the divisor value.
   - Parameter divisor: Double value that we will divide the amount with
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   */
  mutating func divide(_ divisor: Double,
                       roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
    self.amount = calculateDivide(amount: amount.double, divisor: divisor, roundingMode: roundingMode)
  }
  
  /**
   Calculate percentage value for the amount of the current Money item.
   - Note: The percentage value must be in the range from 1 to 100. If the passed value is not in this range we will clamp it to an acceptable value.
   - Parameter percentage: Double percent value that we will apply to the amount
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   */
  mutating func percentage(_ percentage: Double,
                           roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
    self.amount = calculatePercentageAmount(amount: amount.double, percentage: percentage, roundingMode: roundingMode)
  }
  
  /**
   Sets the new value for the _localeIdentifier_ parameter
   - Parameter locale: String value for the _localeIdentifier_ parameter
   */
  mutating func setLocaleIdentifier(_ locale: String) {
    self.localeIdentifier = locale
  }
}

// MARK: - Public Methods - Testing
public extension Money {
  var isPositive: Bool { amount >= .zero }
  var isNegative: Bool { amount < .zero }
  var isZero: Bool { amount == .zero }
  
  /// Check if two Money items has the same amount
  /// - Note: Currency and other parameters are ignored
  func hasSameAmount(_ other: Money) -> Bool {
    self.amount == other.amount
  }
  
  /// Check if two Money items has the same currency
  /// - Note: Amount and other parameters are ignored
  func hasSameCurrency(_ other: Money) -> Bool {
    self.currency == other.currency
  }
  
  /// Check if two Money items are the same
  /// - Important: Both _amount_ **and** _currency_ must be the same
  func isEqual(_ other: Money) -> Bool {
    self.amount == other.amount && self.currency == other.currency
  }
  
  /// Check if one Money item has less amount than the other.
  /// - Note: We need to normalize precisions from two Money items to get them to the same level and after that we can compare them
  /// - Throws: `MoneyError.currencyNotSame` if the currency codes are not the same
  func isLessThan(_ other: Money) throws -> Bool {
    guard self.currency == other.currency else {
      throw MoneyError.currencyNotSame
    }
    let normalizedPrecision = Money.normalizePrecision([self, other])
    return normalizedPrecision[0].amount < normalizedPrecision[1].amount
  }
  
  /// Check if one Money item has less amount than the other or if they are equal.
  /// - Note: We need to normalize precisions from two Money items to get them to the same level and after that we can compare them
  /// - Throws: `MoneyError.currencyNotSame` if the currency codes are not the same
  func isLessThanOrEqual(_ other: Money) throws -> Bool {
    guard self.currency == other.currency else {
      throw MoneyError.currencyNotSame
    }
    let normalizedPrecision = Money.normalizePrecision([self, other])
    return normalizedPrecision[0].amount <= normalizedPrecision[1].amount
  }
  
  /// Check if one Money item value is greater than the other.
  /// - Note: We need to normalize precisions from two Money items to get them to the same level and after that we can compare them
  /// - Throws: `MoneyError.currencyNotSame` if the currency codes are not the same
  func isGreaterThan(_ other: Money) throws -> Bool {
    guard self.currency == other.currency else {
      throw MoneyError.currencyNotSame
    }
    let normalizedPrecision = Money.normalizePrecision([self, other])
    return normalizedPrecision[0].amount > normalizedPrecision[1].amount
  }
  
  /// Check if one Money item value is greater than the other or if they are equal.
  /// - Note: We need to normalize precisions from two Money items to get them to the same level and after that we can compare them
  /// - Throws: `MoneyError.currencyNotSame` if the currency codes are not the same
  func isGreaterThanOrEqual(_ other: Money) throws -> Bool {
    guard self.currency == other.currency else {
      throw MoneyError.currencyNotSame
    }
    let normalizedPrecision = Money.normalizePrecision([self, other])
    return normalizedPrecision[0].amount >= normalizedPrecision[1].amount
  }
}

// MARK: - Private Methods - Static
private extension Money {
  /**
   Normalize precision for the multiple Money objects.
   
   We will get maximum precision value in the array of Money items and use it to convert other items to that level
   - Note: If getting the highest value fails for some reason, we will use `MoneyConstants.defaultPrecision`
   - Parameter objects: Array of the Money objects that we need to get to the same level of precision
   - Returns: An array of the Money objects in the same order as provided, but with applied calculated precision on each element
   */
  static func normalizePrecision(_ objects: [Money]) -> [Money] {
    let highestPrecision = objects.max { $0.precision > $1.precision }?.precision ?? MoneyConstants.defaultPrecision
    return objects.map {
      $0.precision == highestPrecision ? $0 : $0.convertPrecision(highestPrecision)
    }
  }
}

// MARK: - Private Methods - Utils
private extension Money {
  /**
   Round Double amount value to the Int with provided rounding mode
   
   We will round the double value and convert it to Int
   - Parameter amount: Double value amount that we want to round
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: Int value of the provided amount
   */
  func roundToCents(
    _ amount: Double,
    _ roundingMode: FloatingPointRoundingRule
  ) -> Int {
    return Int(amount.rounded(roundingMode))
  }
  
  /**
   Convert precision of the Money object to the provided new precision
   
   We will calculate difference of the new precision and current one and apply it to the amount of the current Money object.
   After that, we need to round the new amount and create new Money object with it.
   - Note: _currency_ and _localeIdentifier_ are used from the original Money item.
   - Parameter newPrecision: Int value of the new precision
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: **new** Money item with the provided precision and calculated amount
   */
  func convertPrecision(
    _ newPrecision: Int,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Money {
    let newAmount = amount.double * pow(10, Double(newPrecision - precision))
    let rounded = roundToCents(newAmount, roundingMode)
    return Money(amount: rounded,
                 currency: currency,
                 localeIdentifier: localeIdentifier,
                 precision: newPrecision)
    
  }
  
  /**
   Calculate multiplication of the provided amount value and the multiplier value.
   - Parameter amount: Double value of the amount that we calculate multiplication
   - Parameter multiplier: Double value that we will multiply the amount with
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: Int value of the multiplication result
   */
  func calculateMultiply(
    amount: Double,
    multiplier: Double,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Int {
    let newAmount = amount * multiplier
    return roundToCents(newAmount, roundingMode)
  }
  
  /**
   Calculate division of the provided amount value and the divisor value.
   - Parameter amount: Double value of the amount that we calculate division
   - Parameter divisor: Double value that we will divide the amount with
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: Int value of the division result
   */
  func calculateDivide(
    amount: Double,
    divisor: Double,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Int {
    let newAmount = amount / divisor
    return roundToCents(newAmount, roundingMode)
  }
  
  /**
   Calculate percentage of the amount value
   - Note: The percentage value must be in the range from 1 to 100. If the passed value is not in this range we will clamp it to an acceptable value.
   - Parameter amount: Double value of the amount that we calculate percentage
   - Parameter percentage: Double percent value that we will apply to the amount
   - Parameter roundingMode: _FloatingPointRoundingRule_ that we will use to round the result. If not passed, default value `.toNearestOrAwayFromZero` will be used
   - Returns: Int value of the amount percentage
   */
  func calculatePercentageAmount(
    amount: Double,
    percentage: Double,
    roundingMode: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Int {
    let clampedPercentage = percentage.clamped(to: 0...100)
    let newAmount = amount * (clampedPercentage / 100.0)
    return roundToCents(newAmount, roundingMode)
  }
}

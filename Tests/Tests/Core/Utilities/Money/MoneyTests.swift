//
//  MoneyTests.swift
//  PovioKit_Tests
//
//  Created by Marko Mijatovic on 04/07/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import XCTest
@testable import PovioKit

class MoneyTests: XCTestCase {
  // MARK: - Testing Getters
  func testGetAmount() {
    let initialAmount: UInt = 100
    let money = Money(cents: initialAmount, currency: .usd)
    XCTAssert(money.cents == initialAmount, "Money amount should be equal to initial value!")
  }
  
  func testGetCurrency() {
    let money = Money(cents: 100, currency: .usd)
    XCTAssert(money.currency == .usd, "Money currency should be equal to initial value!")
  }
  
  func testSameCurrency() {
    let money = Money(cents: 100, currency: .usd)
    let dinero = Money(cents: 200, currency: .usd)
    XCTAssert(money.currency == dinero.currency, "Two Money objects should have the same currencies!")
  }
  
  func testDifferentCurrency() {
    let money = Money(cents: 100, currency: .usd)
    let dinero = Money(cents: 200, currency: .eur)
    XCTAssert(money.currency != dinero.currency, "Two Money objects should have different currencies!")
  }
  
  func testGetLocale() {
    let dinero = Money(cents: 100, currency: .eur, localeIdentifier: "es", precision: 2)
    XCTAssert(dinero.locale.identifier == "es", "Money object should be with Spanish locale!")
  }
  
//  func testChangeLocale() {
//    let dinero = Money(cents: 100, currency: .eur, localeIdentifier: "es", precision: 2)
//      .setLocaleIdentifier("en_US")
//    XCTAssert(dinero.locale.identifier == "en_US", "Money object should be now with US locale!")
//  }
  
  func testGetPrecision() {
    let money = Money(cents: 100, currency: .usd, precision: 3) // 0.1 $
    XCTAssert(money.cents == 10, "Money with 100 cents and precision 3 should have unit value of 0.1!")
  }
  
  func testGetFormatted() {
//    let money = Money(cents: 123457, currency: .usd, localeIdentifier: "en_US")
//    let formattedUS = money.formatted
//    XCTAssert(formattedUS == "$1,234.57", "Money should be formatted correctly!")
//    let dinero = money.setLocaleIdentifier("es")
//    let formattedES = dinero.formatted
//    XCTAssert(formattedES == "1234,57 US$", "Money should be formatted correctly!")
  }
  
  // MARK: - Testing Manipulations
//  func testAdd() {
//    let money = Money(cents: 100, currency: .usd) // 1 $
//    let other = Money(cents: 183456, currency: .usd, precision: 4) // 18.3456 $
//    let cents = (money + other).cents // This should be 193456 cents, or unit value of 19.3456 $
//    XCTAssert(cents == 193456, "Adding Money with different precision should be correct!")
//  }
//
//  func testSubtract() {
//    let money = Money(cents: 2000, currency: .usd) // 20 $
//    let other = Money(cents: 183456, currency: .usd, precision: 4) // 18.3456 $
//    let unitValue = (money - other).unitValue // This should be 16544 cents, or unit value of 1.6544 $
//    XCTAssert(unitValue == 1.6544, "Subtract Money with different precision should be correct!")
//  }
//
//  func testMultiplyByNumber() {
//    let money = Money(cents: 200, currency: .usd) // 2 $
//    let unitValue = money.multiply(4.5).unitValue // This should be 900 cents, or unit value of 9 $
//    XCTAssert(unitValue == 9, "Multiply Money by number should be correct!")
//  }
//
//  func testMultiplyTwoMoneyObjects() {
//    let money = Money(cents: 200, currency: .usd) // 2 $
//    let other = Money(cents: 183456, currency: .usd, precision: 4) // 18.3456 $
//    let unitValue = (money * other).unitValue // This should be 366912 cents, or unit value of 36.6912 $
//    XCTAssert(unitValue == 36.6912, "Multiply two Money objects should be correct!")
//  }
//
//  func testDivideByNumber() {
//    let money = Money(cents: 200, currency: .usd) // 2 $
//    let cents = money.divide(4.5).cents // This should be 44 cents, or unit value of 0.44 $
//    XCTAssert(cents == 44, "Divide Money by number should be correct!")
//  }
  
  func testDivideTwoMoneyObjects() {
    let money = Money(cents: 2000, currency: .usd) // 20 $
    let other = Money(cents: 18345, currency: .usd, precision: 4) // 1.8345 $
    let unitValue = (money / other).unitValue // This should be 1090 cents, or unit value of 10.90 $
    XCTAssert(unitValue == 10.90, "Division of the two Money objects should be correct!")
  }
  
  func testTax() {
    let x = Money(cents: 1995, currency: .usd)
    let y = Money(cents: 55, currency: .usd, precision: 3)
    XCTAssertEqual((x * y).unitValue, <#T##expression2: Equatable##Equatable#>)
  }
  
  func testTax() {
    // https://v2.dinerojs.com/docs/core-concepts/scale
    let m1 = Money(cents: 1995, currency: .usd)
    let m2 = Money(cents: 55, currency: .usd, precision: 3)
    let total = m1 * m2 + m1
    XCTAssertEqual(total.unitValue, 21.04725)
  }
  
  // MARK: - Testing Comparison
  func testIsPositive() {
    let money = Money(cents: 2000, currency: .usd)  // 20 $
    XCTAssertTrue(money.isPositive, "Money should be positive!")
//    let debt = money.multiply(-1)
//    XCTAssertTrue(debt.isNegative, "Debt money should be negative!")
  }
  
  func testIsZero() {
    let money = Money(cents: 0, currency: .usd)
    XCTAssertTrue(money.isZero, "Money should be zero!")
  }
  
  func testIsEqual() {
    let money = Money(cents: 200, currency: .usd)  // 2 $
    let other = Money(cents: 2000, currency: .usd, precision: 3)  // 2 $
    XCTAssertTrue(money == other, "Two Money objects should be the same!")
    XCTAssertTrue(money >= other, "One Money objects should be greater than or equal the other!")
    XCTAssertTrue(money <= other, "One Money objects should be less than or equal the other!")
  }
  
  func testIsEqualDifferentCurrency() {
    let money = Money(cents: 200, currency: .usd)  // 2 $
    let other = Money(cents: 2000, currency: .eur, precision: 3)  // 2 €
    XCTAssertFalse(money == other, "Two Money objects with different currency should NOT be the same!")
  }
  
  func testIsGreater() {
    let money = Money(cents: 200, currency: .usd)  // 2 $
    let other = Money(cents: 1990, currency: .usd, precision: 3)  // 1.99 $
    XCTAssertTrue(money > other, "One Money objects should be greater than the other!")
    XCTAssertTrue(money >= other, "One Money objects should be greater than or equal the other!")
  }
  
  func testIsLess() {
    let money = Money(cents: 199, currency: .usd)  // 1.99 $
    let other = Money(cents: 2000, currency: .usd, precision: 3)  // 2 $
    XCTAssertTrue(money < other, "One Money objects should be less than the other!")
    XCTAssertTrue(money <= other, "One Money objects should be less than or equal the other!")
  }
}

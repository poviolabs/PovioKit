//
//  ValidationFormRow.swift
//  
//
//  Created by Toni K. Turk on 19/04/2022.
//

import Foundation

public protocol IsValid {
  var isValid: Bool { get }
}

public protocol ValidationStatusConforming: IsValid {
  associatedtype Valid
  associatedtype Invalid
  associatedtype Pending
  static func valid(_: Valid) -> Self
  static func invalid(_: Invalid) -> Self
  static func pending(_: Pending) -> Self
}

public extension ValidationStatusConforming where Valid == () {
  static var valid: Self { .valid(()) }
}

public extension ValidationStatusConforming where Invalid == () {
  static var invalid: Self { .invalid(()) }
}

public extension ValidationStatusConforming where Pending == () {
  static var pending: Self { .pending(()) }
}

public protocol ValidationFormCell: DynamicCollectionCell {}

public protocol BaseValidationFormRowType: AnyObject {
  var key: String? { get }
  var placeholder: String? { get }
  var keyValuePair: (key: String, value: Any)? { get }
  var didSelectCallback: (() -> Void)? { get }
  func updateValue(_ value: Any?)
  func validate()
  func validationForm(
    _ validationForm: ValidationForm,
    cellForRowAt indexPath: IndexPath,
    in collectionView: UICollectionView
  ) -> ValidationFormCell
}

extension BaseValidationFormRowType {
  var key: String? { nil }
  var placeholder: String? { nil }
  var keyValuePair: (key: String, value: Any)? { nil }
  var didSelectCallback: (() -> Void)? { nil }
  func updateValue(_ value: Any?) {}
  func validate() {}
}

public protocol TypedValidationFormRowType: BaseValidationFormRowType {
  associatedtype Value
  var value: Value? { get set }
}

public extension TypedValidationFormRowType where Self: BaseValidationFormRowType {
  var keyValuePair: (key: String, value: Any)? {
    switch (key, value) {
    case let (key?, value?):
      return (key, value)
    case _:
      return nil
    }
  }
  
  func updateValue(_ value: Any?) {
    self.value = value as? Value
  }
  
  func updateValue(_ value: Value) {
    self.value = value
  }
}

public extension TypedValidationFormRowType where Self: BaseValidationFormRowType, Value == String {
  func updateValue(_ value: Any) {
    self.value = (value as? CustomStringConvertible)?.description
  }
}

extension Optional: CustomStringConvertible where Wrapped: CustomStringConvertible {
  public var description: String { map { $0.description } ?? "" }
}

public protocol ValidatableValidationFormRowType: TypedValidationFormRowType {
  associatedtype ValidationStatus: ValidationStatusConforming
  typealias Validator = (Value?) -> ValidationStatus
  var validator: Validator { get }
  var validationStatus: ValidationStatus { get set }
}

extension ValidatableValidationFormRowType where Self: BaseValidationFormRowType {
  public func validate() {
    validationStatus = validator(value)
  }
}

@resultBuilder
enum ValidationFormBuilder {
  public static func buildBlock(_ partialResults: BaseValidationFormRowType...) -> [BaseValidationFormRowType] {
    partialResults
  }
}

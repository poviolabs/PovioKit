//
//  ValidationForm.swift
//  PovioKit
//
//  Created by Toni Kocjan on 08/08/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

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

open class ValidationForm: NSObject, UICollectionViewDataSource {
  private var form: [BaseValidationFormRowType] = []
  
  public init(@ValidationFormBuilder build: () -> [BaseValidationFormRowType]) {
    self.form = build()
  }
  
  public override init() {
    self.form = []
    super.init()
  }
  
  // MARK: - UICollectionViewDataSource
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    form.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let row = form[safe: indexPath.row] else {
      fatalError("No row at `\(indexPath)`!")
    }
    return row.validationForm(self, cellForRowAt: indexPath, in: collectionView)
  }
}

// MARK: - API
public extension ValidationForm {
  @discardableResult
  func validate(in collectionView: UICollectionView) -> Bool {
    for row in form {
      row.validate()
    }
    collectionView.reloadDataKeepingContentOffset()
    return isFormValid
  }
  
  func validateRow(at index: Int, in collectionView: UICollectionView) -> Bool {
    guard let row = form[safe: index] else { return true }
    row.validate()
    collectionView.reloadDataKeepingContentOffset()
    return isRowValid(row)
  }
  
  func validateRow(key: String, in collectionView: UICollectionView) -> Bool {
    guard let rowIndex = form.firstIndex(where: { $0.key == key }) else { return true }
    return validateRow(at: rowIndex, in: collectionView)
  }
  
  var isFormValid: Bool {
    form.allSatisfy(isRowValid)
  }
  
  func generate<D: Decodable>(_ model: D.Type, decoder: JSONDecoder) throws -> D {
    let json = form
      .compactMap { $0.keyValuePair }
      .reduce(into: [String: Any]()) { $0.updateValue($1.value, forKey: $1.key) }
      .filter { !(($0.value as? String)?.isEmpty ?? true) }
    let data = try JSONSerialization.data(withJSONObject: json, options: [])
    return try decoder.decode(model, from: data)
  }
  
  func populateForm<T>(_ model: T, in collectionView: UICollectionView) {
    for (label, value) in Mirror(reflecting: model).children {
      guard let label = label else { continue }
      guard let row = form.first(where: { $0.key == label }) else { continue }
      row.updateValue(value)
    }
    collectionView.reloadDataKeepingContentOffset()
  }
  
  func row<Value, Status, R: ValidatableValidationFormRowType>(
    at index: Int
  ) -> R? where R.Value == Value, R.ValidationStatus == Status {
    form[safe: index] as? R
  }
  
  func updateRow<R: ValidatableValidationFormRowType>(
    _ type: R.Type,
    value: R.Value?,
    at indexPath: IndexPath
  ) {
    guard let row: R = row(at: indexPath.row) else { return }
    row.updateValue(value)
    row.validate()
  }
  
  func updateRow(key: String, value: Any?, in collectionView: UICollectionView) {
    guard let rowIndex = rowIndex(key: key) else { return }
    form[rowIndex].updateValue(value)
    form[rowIndex].validate()
    collectionView.reloadItems(at: [.init(row: rowIndex, section: 0)])
  }
  
  func updateValidationStatus<R: ValidatableValidationFormRowType>(
    _ type: R.Type,
    key: String,
    validationStatus: R.ValidationStatus,
    in collectionView: UICollectionView
  ) {
    guard let rowIndex = rowIndex(key: key) else { return }
    guard let row = form[rowIndex] as? R else { return }
    row.validationStatus = validationStatus
    collectionView.reloadItems(at: [.init(row: rowIndex, section: 0)])
  }
  
  func appendRow<R: BaseValidationFormRowType>(_ row: R) {
    form.append(row)
  }
  
  func appendRows(_ rows: [BaseValidationFormRowType]) {
    form.append(contentsOf: rows)
  }
  
  func appendRows(_ rows: BaseValidationFormRowType...) {
    form.append(contentsOf: rows)
  }
  
  func rowIndex(key: String) -> Int? {
    form.firstIndex { $0.key == key }
  }
  
  subscript(indexPath: IndexPath) -> BaseValidationFormRowType? {
    form[safe: indexPath.row]
  }
}

extension ValidationForm {
  func isRowValid(_ row: BaseValidationFormRowType) -> Bool {
    for (label, value) in Mirror(reflecting: row).children {
      guard label == "validationStatus", let valid = value as? IsValid else { continue }
      return valid.isValid
    }
    return true
  }
}

extension UICollectionView {
  func reloadDataKeepingContentOffset() {
    let contentOffset = self.contentOffset
    reloadData()
    layoutIfNeeded()
    DispatchQueue.main.async {
      self.setContentOffset(contentOffset, animated: false)
    }
  }
}

//
//  ValidationForm.swift
//  PovioKit
//
//  Created by Toni Kocjan on 08/08/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import PovioKit
import UIKit

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
  /// Validate the form.
  ///
  /// - Returns: True if the form is valid, false otherwise.
  @discardableResult
  func validate(in collectionView: UICollectionView) -> Bool {
    for row in form {
      row.validate()
    }
    collectionView.reloadDataKeepingContentOffset()
    return isFormValid
  }
  
  /// Validate a single row.
  ///
  /// - Parameter index: The index of a row in the form.
  /// - Returns: True if the row is valid, false otherwise.
  func validateRow(at index: Int, in collectionView: UICollectionView) -> Bool {
    guard let row = form[safe: index] else { return true }
    row.validate()
    collectionView.reloadDataKeepingContentOffset()
    return isRowValid(row)
  }
   
  /// Validate a single row.
  ///
  /// - Parameter key: The key of the row.
  /// - Returns: True if the row is valid, false otherwise.
  func validateRow(key: String, in collectionView: UICollectionView) -> Bool {
    guard let rowIndex = form.firstIndex(where: { $0.key == key }) else { return true }
    return validateRow(at: rowIndex, in: collectionView)
  }
  
  /// - Returns: True if the form is valid, false otherwise.
  var isFormValid: Bool {
    form.allSatisfy(isRowValid)
  }
  
  /// Given a Decodable type, it generates it with the filled data inside the form, or throws an error
  /// if unable to do so.
  ///
  /// - Parameter model: A type conforming to Decodable.
  /// - Parameter decoder: A JSONDecoder instance.
  /// - Returns: An instance of type D.
  func generate<D: Decodable>(_ model: D.Type, decoder: JSONDecoder) throws -> D {
    let json = form
      .compactMap { $0.keyValuePair }
      .reduce(into: [String: Any]()) { $0.updateValue($1.value, forKey: $1.key) }
      .filter { !(($0.value as? String)?.isEmpty ?? true) }
    let data = try JSONSerialization.data(withJSONObject: json, options: [])
    return try decoder.decode(model, from: data)
  }
  
  /// Fill the contents of the form with a model of any type T.
  ///
  /// Under the hood, this method uses reflection to extract data
  /// and will match labels with keys inside the form. Note that types must also match,
  /// if they don't, a field won't get populated.
  ///
  /// - Parameters model: A model of any type that contains data to populate form
  func populateForm<T>(_ model: T, in collectionView: UICollectionView) {
    for (label, value) in Mirror(reflecting: model).children {
      guard let label = label else { continue }
      guard let row = form.first(where: { $0.key == label }) else { continue }
      row.updateValue(value)
    }
    collectionView.reloadDataKeepingContentOffset()
  }
  
  /// Get a (typed) row at given index
  ///
  /// - Parameter index: The index of a row
  func row<Value, Status, R: ValidatableValidationFormRowType>(
    at index: Int
  ) -> R? where R.Value == Value, R.ValidationStatus == Status {
    form[safe: index] as? R
  }
  
  /// Update the value of a row at a given index.
  ///
  /// - Parameter type: A type of the row.
  /// - Parameter value: Value with which to update the row.
  /// - Parameter indexPath: IndexPath of the row.
  func updateRow<R: ValidatableValidationFormRowType>(
    _ type: R.Type,
    value: R.Value?,
    at indexPath: IndexPath
  ) {
    guard let row: R = row(at: indexPath.row) else { return }
    row.updateValue(value)
    row.validate()
  }
  
  /// Update the value of a row given a key.
  ///
  /// - Parameter key: The key with which to find the row.
  /// - Parameter value: Value with which to update the row.
  func updateRow(key: String, value: Any?, in collectionView: UICollectionView) {
    guard let rowIndex = rowIndex(key: key) else { return }
    form[rowIndex].updateValue(value)
    form[rowIndex].validate()
    collectionView.reloadItems(at: [.init(row: rowIndex, section: 0)])
  }
  
  /// Update the validation status of a row given a key.
  ///
  /// - Parameter type: A type of the row.
  /// - Parameter key: The key with which to find the row.
  /// - Parameter validationStatus: The new validation status.
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
  
  /// Apend a row to the form.
  func appendRow<R: BaseValidationFormRowType>(_ row: R) {
    form.append(row)
  }
  
  /// Append multiple rows to the form.
  func appendRows(_ rows: [BaseValidationFormRowType]) {
    form.append(contentsOf: rows)
  }
  
  /// Append multiple rows to the form.
  func appendRows(_ rows: BaseValidationFormRowType...) {
    form.append(contentsOf: rows)
  }
  
  /// Get the index of a row given a key.
  func rowIndex(key: String) -> Int? {
    form.firstIndex { $0.key == key }
  }
  
  /// Subscript the form based on index path.
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

class Row: BaseValidationFormRowType {
  
  
  func validationForm(_ validationForm: ValidationForm, cellForRowAt indexPath: IndexPath, in collectionView: UICollectionView) -> ValidationFormCell {
    fatalError()
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

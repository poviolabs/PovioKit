//
//  UITableView+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

public extension UITableView {
  func register<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.identifier)
  }
  
  func register<T: UITableViewHeaderFooterView>(_: T.Type) {
    register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.identifier)")
    }
    return cell
  }
  
  func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type, at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
      print("Could not dequeue cell with identifier: \(T.identifier). Creating new instance.")
      return T()
    }
    return cell
  }
  
  func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
    guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
      fatalError("Could not dequeue headerFooter view with identifier: \(T.identifier)")
    }
    return view
  }
  
  func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerFooter: T.Type) -> T {
    guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
      print("Could not dequeue headerFooter view with identifier: \(T.identifier)")
      return T()
    }
    return view
  }
  
  /// Deselect row at selected index path
  func deselectSelectedRow(animated: Bool = true) {
    if let selectedRow = indexPathForSelectedRow {
      deselectRow(at: selectedRow, animated: animated)
    }
  }
  
  /// Scroll table to first row at top
  func scrollToTop(animated: Bool = true) {
    if numberOfSections > 0 && numberOfRows(inSection: 0) > 0 {
      scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
    }
  }
  
  /// Scroll table to last row in last section
  func scrollToBottom(animated: Bool = true) {
    guard numberOfSections > 0 else { return }
    
    let lastSection = max(0, numberOfSections - 1)
    let lastRow = max(0, numberOfRows(inSection: lastSection) - 1)
    scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: animated)
  }
}

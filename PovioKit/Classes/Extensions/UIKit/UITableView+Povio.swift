//
//  UITableView+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//
import UIKit

public extension UITableView {
  func register<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
  }
  
  func register<T: UITableViewHeaderFooterView>(_: T.Type) {
    register(T.self, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
    }
    return cell
  }
  
  func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type, at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      print("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier). Creating new instance.")
      return T()
    }
    return cell
  }
  
  func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
    guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as? T else {
      fatalError("Could not dequeue headerFooter view with identifier: \(T.defaultReuseIdentifier)")
    }
    return view
  }
  
  func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerFooter: T.Type) -> T {
    guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as? T else {
      print("Could not dequeue headerFooter view with identifier: \(T.defaultReuseIdentifier)")
      return T()
    }
    return view
  }
}

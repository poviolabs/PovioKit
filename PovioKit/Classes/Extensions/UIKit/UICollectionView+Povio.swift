//
//  UICollectionView+Povio.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

public extension UICollectionView {    
  func register<T: UICollectionViewCell>(_: T.Type) {
    register(T.self, forCellWithReuseIdentifier: T.identifier)
  }
  
  func registerSupplementaryView<T: UICollectionReusableView>(_: T.Type, kind: String) {
    register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.identifier)
  }
  
  func register<T: UICollectionReusableView>(headerView: T.Type) {
    registerSupplementaryView(headerView, kind: UICollectionView.elementKindSectionHeader)
  }
  
  func register<T: UICollectionReusableView>(footerView: T.Type) {
    registerSupplementaryView(footerView, kind: UICollectionView.elementKindSectionFooter)
  }
  
  func dequeuReusableCell<T: UICollectionViewCell>(at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.identifier)")
    }
    return cell
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(_ cell: T.Type, at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      print("Could not dequeue cell with identifier: \(T.identifier). Creating new instance.")
      return T()
    }
    return cell
  }
  
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, at indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("Could not dequeue supplementary view (\(kind)) with identifier: \(T.identifier)")
    }
    return view
  }
  
  /// Dequeue reusable header view
  func dequeueReusableHeaderView<T: UICollectionReusableView>(_ view: T.Type, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      return T()
    }
    return view
  }
  
  /// Dequeue reusable footer view
  func dequeueReusableFooterView<T: UICollectionReusableView>(_ view: T.Type, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      return T()
    }
    return view
  }
}

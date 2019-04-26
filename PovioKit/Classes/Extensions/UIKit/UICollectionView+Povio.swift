//
//  UICollectionView+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/4/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit

public extension UICollectionView {    
  func register<T: UICollectionViewCell>(_: T.Type) {
    register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
  }
  
  func registerSupplementaryView<T: UICollectionReusableView>(_: T.Type, kind: String) {
    register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
  }
  
  func dequeuReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
    }
    return cell
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(_ cell: T.Type, at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      print("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier). Creating new instance.")
      return T()
    }
    return cell
  }
  
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue supplementary view (\(kind)) with identifier: \(T.defaultReuseIdentifier)")
    }
    return view
  }
}

//
//  Optional+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
}

public extension Optional where Wrapped == String {
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
  
  func replacingString(with replacementString: String, range: NSRange) -> String {
    NSString(string: self ?? "").replacingCharacters(in: range, with: replacementString) as String
  }
}

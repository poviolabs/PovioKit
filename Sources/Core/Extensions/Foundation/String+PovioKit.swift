//
//  String+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public extension String {
  /// Returns localized string for the current locale. If the key doesn't exist, `self` is returned.
  func localized(_ args: CVarArg...) -> String {
    guard !isEmpty else { return self }
    let localizedString = NSLocalizedString(self, comment: "")
    return withVaList(args) { NSString(format: localizedString, locale: Locale.current, arguments: $0) as String }
  }
  
  /// Trim white spaces from both ends
  var trimed: String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  /// Returns digits only from string
  var digits: String {
    components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
  }
  
  /// Returns base64 encoded string
  var base64: String? {
    data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
  }
  
  /// Email validation
  var isEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
  
  /// Returns substring containing up to `maxLength` characters from the beginning of the string.
  ///
  /// This method is just a wrapper around swift's standard library `prefix` method, but it ensures only positive values are accepted.
  func safePrefix(_ maxLength: UInt) -> Substring {
    prefix(Int(maxLength))
  }
  
  /// Returns substring containing up to `maxLength` characters from the end of the string.
  ///
  /// This method is just a wrapper around swift's standard library `suffix` method, but it ensures only positive values are accepted.
  func safeSuffix(_ maxLength: UInt) -> Substring {
    suffix(Int(maxLength))
  }
}

//
//  String+Povio.swift
//  PovioKit
//
//  Created by Povio on 26/04/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import Foundation

public extension String {
  /// Returns localized string for the current locale. If the key doesn't exist, `self` is returned.
  func localized(_ args: CVarArg...) -> String {
    guard !self.isEmpty else { return self }
    let localizedString = NSLocalizedString(self, comment: "")
    return withVaList(args) { NSString(format: localizedString, locale: Locale.current, arguments: $0) as String }
  }
}

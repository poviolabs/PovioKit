//
//  Collection+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 12/03/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

public extension String {
	func localized(_ args: CVarArg...) -> String {
		guard !self.isEmpty else { return self }
		let localizedString = NSLocalizedString(self, comment: "")
		return withVaList(args) { NSString(format: localizedString, locale: Locale.current, arguments: $0) as String }
	}
}

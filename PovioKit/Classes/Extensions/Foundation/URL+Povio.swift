//
//  Collection+Povio.swift
//  PovioKit
//
//  Created by Povio on 12/03/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

extension URL {
	init?(string: String?) {
		guard let string = string else { return nil }
		self.init(string: string)
	}
}

extension URL: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		guard let url = URL(string: value) else {
			fatalError("Invalid URL string.")
		}
		self = url
	}
}

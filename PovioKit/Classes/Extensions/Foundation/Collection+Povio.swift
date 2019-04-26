//
//  Collection+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 12/03/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

public extension Collection {
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index]: nil
	}
	
	func count(where clause: (Element) -> Bool) -> Int {
		return lazy.filter(clause).count
	}
}

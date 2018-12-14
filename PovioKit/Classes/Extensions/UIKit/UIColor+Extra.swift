//
//  UICollectionView+Extra.swift
//  PovioKit
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

public extension UIColor {
	/// Init color from RGB
	public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
		self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
	}
}

// MARK: - Theme Colors
public extension UIColor {
  // TODO
}

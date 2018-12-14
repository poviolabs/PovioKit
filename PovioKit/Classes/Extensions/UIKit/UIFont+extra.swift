//
//  UIFont+extra.swift
//  PovioKit
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import UIKit

public enum FontStyle: String {
  static let fontFamilyName = "[insert-font-family-name]"
  
  // TODO: - Enumerate all styles ...
  case none

  var name: String {
    return "\(FontStyle.fontFamilyName)-\(rawValue)"
  }
}

extension UIFont {
  static func custom(type: FontStyle, size: CGFloat) -> UIFont {
    return UIFont(name: type.name, size: size) ?? .systemFont(ofSize: size)
  }
	
	static func dynamicCustom(type: FontStyle, multiplier: CGFloat, maxSize: CGFloat) -> UIFont {
		let size = round(min(maxSize, UIScreen.main.bounds.height * multiplier))
		return UIFont(name: type.name, size: size) ?? .systemFont(ofSize: size)
	}	
}

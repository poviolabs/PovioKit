//
//  Component.swift
//  Storybook
//
//  Created by Borut Tomazin on 23/01/2023.
//

import Foundation

enum Component: String, Identifiable, Hashable, CaseIterable {
  case actionButton
  case paddingLabel
  
  var id: RawValue { rawValue }
  
  var name: String {
    switch self {
    case .actionButton:
      return "Action Button"
    case .paddingLabel:
      return "Padding Label"
    }
  }
}

//
//  Component.swift
//  Storybook
//
//  Created by Borut Tomazin on 23/01/2023.
//

import Foundation

enum Component: CaseIterable {
  case actionButton
  case paddingLabel
}

extension Component {
  var name: String {
    switch self {
    case .actionButton:
      return "Action Button"
    case .paddingLabel:
      return "Padding Label"
    }
  }
}

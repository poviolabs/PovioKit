//
//  Component.swift
//  Storybook
//
//  Created by Borut Tomazin on 23/01/2023.
//

import Foundation

enum Component: CaseIterable {
  case photoPicker
  case animatedImage
}

extension Component {
  var name: String {
    switch self {
    case .photoPicker:
      return "Photo Picker"
    case .animatedImage:
      return "Animated Image / GIF"
    }
  }
}

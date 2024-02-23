//
//  TextFieldLimitModifer.swift
//  PovioKit
//
//  Created by Dejan Skledar on 29/12/2023.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
struct TextFieldLimitModifer: ViewModifier {
  @Binding var text: String
  let limit: Int
  
  func body(content: Content) -> some View {
    content
      .onChange(of: text) { newValue in
        guard newValue.count > limit else { return }
        text = String(newValue.prefix(limit))
      }
  }
}

@available(iOS 15.0, *)
extension View {
  /// Limit input length
  func limitInput(text: Binding<String>, limit: Int) -> some View {
    self.modifier(TextFieldLimitModifer(text: text, limit: limit))
  }
}

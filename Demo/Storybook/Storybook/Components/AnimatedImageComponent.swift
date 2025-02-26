//
//  AnimatedImageComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//

import SwiftUI
import PovioKitSwiftUI

struct AnimatedImageComponent: View {
  var body: some View {
    if let url = URL(string: "https://shorturl.at/9q4YZ") {
      AnimatedImage(source: .remote(url: url))
        .squared()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
          RoundedRectangle(cornerRadius: 10)
            .stroke(.gray, lineWidth: 1)
        }
        .padding(20)
    }
  }
}

#Preview {
  AnimatedImageComponent()
}

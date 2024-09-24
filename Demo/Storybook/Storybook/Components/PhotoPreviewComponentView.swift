//
//  PhotoPreviewComponentView.swift
//  Storybook
//
//  Created by Ndriqim Nagavci on 19/09/2024.
//

import PovioKitSwiftUI
import SwiftUI

struct PhotoPreviewComponentView: View {
  @State private var showPhotoPreview = false
  private var items: [PhotoPreview.Item] = [
    .init(image: Image("PovioKit")),
    .init(url: .init(string: "https://raw.githubusercontent.com/poviolabs/PovioKit/develop/Resources/PovioKit.png"))
  ]
  
  var body: some View {
    Button {
      showPhotoPreview.toggle()
    } label: {
      Text("Show Photo Preview")
    }
    .photoPreview(
      present: $showPhotoPreview,
      items: items
    )
  }
}

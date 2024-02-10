//
//  URLImageView.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/23/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

struct URLImageView: View {
  @ObservedObject var urlImageModel: URLImageModel
  var placeholderImage: Image?
  
  init(from url: URL?, placeholder: Image?) {
    self.placeholderImage = placeholder
    urlImageModel = URLImageModel(url: url)
  }
  
  var body: some View {
    createImage(urlImageModel.image, placeholder: placeholderImage)
      .resizable()
  }
  
  func createImage(_ image: ImageContainer?, placeholder: Image?) -> Image {
    if let fetchedImage = image {
#if os(iOS)
      return Image(uiImage: fetchedImage)
#elseif os(macOS)
      return Image(nsImage: fetchedImage)
#endif
    }
    
    if let placeholder = placeholder {
      return placeholder
    }
    
#if os(iOS)
    return Image(uiImage: ImageContainer())
#elseif os(macOS)
    return Image(nsImage: ImageContainer())
#endif
  }
}

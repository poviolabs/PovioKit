//
//  Image+PovioKit.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/22/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

public extension Image {}

#if canImport(Kingfisher)
import Kingfisher

private extension Image {
  func resolveWithKingFisher(from url: URL?, placeholder: Image?) -> some View {
    KFImage(url)
      .resizable()
      .placeholder {
        (placeholder ?? Image(uiImage: UIImage()))
          .resizable()
      }
  }
}
#endif

extension Image {
  func resolve(from url: URL?, placeholder: Image?) -> some View {
    #if canImport(KingFisher)
      return resolveWithKingFisher(from: url, placeholder: placeholder)
    #else
      return URLImageView(from: url, placeholder: placeholder)
    #endif
  }
}

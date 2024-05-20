//
//  Image+PovioKit.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/22/22.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
public extension Image {}

#if canImport(Kingfisher)
import Kingfisher

@available(iOS 14, *)
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

//
//  SwiftUIView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/02/2025.
//

#if canImport(Kingfisher)
import Kingfisher
import SwiftUI

/// A view that displays an animated image either from a local file or a remote URL.
///
/// It uses `Kingfisher` for handling the image loading from both sources.
struct AnimatedImage: View {
  let source: Source
  
  var body: some View {
    switch source {
    case .local(let fileName):
      if let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "gif") {
        KFAnimatedImage(source: .provider(LocalFileImageDataProvider(fileURL: fileUrl)))
      }
    case .remote(let url):
      KFAnimatedImage(url)
    }
  }
}

extension AnimatedImage {
  /// Enum representing the source of the animated image.
  enum Source {
    case local(fileName: String)
    case remote(url: URL)
  }
}
#endif

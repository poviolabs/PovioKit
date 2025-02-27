//
//  RemoteImage.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI
#if canImport(Kingfisher)
import Kingfisher
#endif

/// A view that asynchronously loads and displays an image from the provided URL.
///
/// If Kingfisher is available, it uses `KFImage` for image loading to support caching,
/// otherwise it falls back to SwiftUI's `AsyncImage`.
///
/// The `RemoteImage` can be parameterized with a custom placeholder view and an
/// option for fade animation.
///
/// ## Example with placeholder
/// ```swift
/// RemoteImage(url: URL(string: "https://example.com/image.jpg"), animated: true)
///   .placeholder {
///     Text("Loading...")
///       .foregroundColor(.gray)
///   }
/// ```
@available(iOS 15.0, *)
public struct RemoteImage<Placeholder: View>: View {
  private let url: URL?
  private let animated: Bool
  private var placeholder: Placeholder?
  
  public init(url: URL?, animated: Bool = false) where Placeholder == EmptyView {
    self.url = url
    self.animated = animated
    self.placeholder = EmptyView()
  }
  
  private init(url: URL?, animated: Bool = false, placeholder: Placeholder?) {
    self.url = url
    self.animated = animated
    self.placeholder = placeholder
  }
  
  public var body: some View {
    if let url {
#if canImport(Kingfisher)
      KFImage(url)
        .placeholder {
          placeholder
        }
        .fade(duration: animated ? 0.25 : 0)
        .resizable()
        .scaledToFill()
#else
      AsyncImage(url: url) { image in
        image
          .resizable()
          .scaledToFill()
      } placeholder: {
        placeholder
      }
#endif
    } else {
      placeholder
    }
  }
}

@available(iOS 15.0, *)
public extension RemoteImage {
  /// Sets a custom placeholder view for the `RemoteImage`.
  ///
  /// - Parameter placeholder: A view builder that creates a placeholder view displayed
  ///   while the image is loading or if the URL is `nil`.
  /// - Returns: A new `RemoteImage` instance with the specified placeholder.
  func placeholder<NewPlaceholder: View>(
    @ViewBuilder placeholder: () -> NewPlaceholder
  ) -> RemoteImage<NewPlaceholder> {
    RemoteImage<NewPlaceholder>(
      url: url,
      animated: animated,
      placeholder: placeholder()
    )
  }
}

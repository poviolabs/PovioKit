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

@available(iOS 15.0, *)
public struct RemoteImage<Placeholder: View>: View {
  private let url: URL?
  private var placeholder: Placeholder?
  
  public init(url: URL?) where Placeholder == EmptyView {
    self.url = url
    self.placeholder = EmptyView()
  }
  
  private init(url: URL?, placeholder: Placeholder?) {
    self.url = url
    self.placeholder = placeholder
  }
  
  public var body: some View {
    if let url {
#if canImport(Kingfisher)
      KFImage(url)
        .placeholder {
          placeholder
        }
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
  func placeholder<NewPlaceholder: View>(
    @ViewBuilder placeholder: () -> NewPlaceholder
  ) -> RemoteImage<NewPlaceholder> {
    RemoteImage<NewPlaceholder>(
      url: url,
      placeholder: placeholder()
    )
  }
}

//
//  RemoteImage.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if canImport(Kingfisher)
import Kingfisher
import SwiftUI

@available(iOS 15.0, *)
public struct RemoteImage<Placeholder: View>: View {
  private let url: URL?
  private let placeholder: Placeholder?
  
  public init(url: URL?, @ViewBuilder _ placeholder: @escaping () -> Placeholder) {
    self.url = url
    self.placeholder = placeholder()
  }
  
  public init(url: URL?) {
    self.url = url
    self.placeholder = nil
  }
  
  public var body: some View {
    KFImage(url)
      .placeholder {
        placeholder
      }
      .resizable()
      .scaledToFill()
  }
}
#endif

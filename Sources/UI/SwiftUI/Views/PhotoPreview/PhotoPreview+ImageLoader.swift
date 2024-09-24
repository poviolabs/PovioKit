//
//  PhotoPreview+ImageLoader.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 23/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
extension PhotoPreview {
  @MainActor
  class ImageLoader: ObservableObject {
    @Published private(set) var state: State = .initial
    
    func loadImage(from url: URL?) async {
      guard let url else { return }
      state = .loading
      let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
      do {
        let (data, _) = try await URLSession.shared.data(for: request)
        await getImageFrom(data: data)
      } catch {
        state = .failed
      }
    }
    
    func getImageFrom(data: Data) async {
      guard let loadedImage = UIImage(data: data) else {
        state = .failed
        return
      }
      withAnimation(.linear(duration: 1)) {
        state = .loaded(loadedImage)
      }
    }
  }
}

// MARK: - State
@available(iOS 15.0, *)
extension PhotoPreview.ImageLoader {
  enum State: Equatable {
    case initial
    case loading
    case loaded(UIImage)
    case failed
  }
}

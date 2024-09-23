//
//  PhotoPreviewImageLoader.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 23/09/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@MainActor
class PhotoPreviewImageLoader: ObservableObject {
  @Published private(set) var state: State = .loading
  
  func loadImage(from url: URL?) async {
    guard let url else { return }
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
    state = .loaded(loadedImage)
  }
}

// MARK: - State
extension PhotoPreviewImageLoader {
  enum State: Equatable {
    case loading
    case loaded(UIImage)
    case failed
  }
}

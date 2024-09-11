//
//  URLImageModel.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/22/22.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias ImageContainer = UIImage 
#elseif os(macOS)
public typealias ImageContainer = NSImage
#endif
import SwiftUI

@MainActor
class URLImageModel: ObservableObject {
  @Published var image: ImageContainer?
  var url: URL?
  
  init(url: URL?) {
    self.url = url
    Task { await loadImage() }
  }
  
  func loadImage() async {
    guard let url = url else { return }
    
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      await getImageFrom(data: data)
    } catch {
      debugPrint("Failed to load image: \(error.localizedDescription)")
    }
  }
  
  func getImageFrom(data: Data) async {
    guard let loadedImage = ImageContainer(data: data) else {
      return
    }
    self.image = loadedImage
  }
}

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

class URLImageModel: ObservableObject {
  @Published var image: ImageContainer?
  var url: URL?
  
  init(url: URL?) {
    self.url = url
    loadImage()
  }
  
  func loadImage() {
    guard let url = url else {
      return
    }
    
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    let task = URLSession.shared.dataTask(with: request, completionHandler: getImageFromResponse(data:response:error:))
    task.resume()
  }
  
  
  func getImageFromResponse(data: Data?, response: URLResponse?, error: Error?) {
    guard let data = data, error == nil else { return }
    
    DispatchQueue.main.async {
      guard let loadedImage = ImageContainer(data: data) else {
        return
      }
      self.image = loadedImage
    }
  }
}

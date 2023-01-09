//
//  URLImageModel.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/22/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 14, *)
class URLImageModel: ObservableObject {
  @Published var image: UIImage?
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
      guard let loadedImage = UIImage(data: data) else {
        return
      }
      self.image = loadedImage
    }
  }
}


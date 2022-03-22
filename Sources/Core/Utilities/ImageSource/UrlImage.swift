//
//  UrlImage.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/22/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 14, *)
class UrlImageModel: ObservableObject {
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
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: getImageFromResponse(data:response:error:))
    task.resume()
  }
  
  
  func getImageFromResponse(data: Data?, response: URLResponse?, error: Error?) {
    guard error == nil else {
      print("Error: \(error!)")
      return
    }
    guard let data = data else {
      print("No data found")
      return
    }
    
    DispatchQueue.main.async {
      guard let loadedImage = UIImage(data: data) else {
        return
      }
      self.image = loadedImage
    }
  }
}

@available(iOS 14, *)
struct UrlImageView: View {
  @ObservedObject var urlImageModel: UrlImageModel
  var placeholderImage: Image?
  
  init(from url: URL?, placeholder: Image?) {
    self.placeholderImage = placeholder
    urlImageModel = UrlImageModel(url: url)
  }
  
  var body: some View {
    createImage(urlImageModel.image, placeholder: placeholderImage)
      .resizable()
  }
  
  func createImage(_ image: UIImage?, placeholder: Image?) -> Image {
    if let fetchedImage = image {
      return Image(uiImage: fetchedImage)
    }
    
    if let placeholder = placeholder {
      return placeholder
    }
    
    return Image(uiImage: UIImage())
  }
}

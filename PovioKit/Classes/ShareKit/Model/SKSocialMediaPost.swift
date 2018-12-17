//
//  SKSocialMediaPost.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Foundation

public struct SKSocialMediaPost {
  public let id: String
  public let title: String
  public let content: String
  public let imageUrls: [URL]
  public let url: URL?
  public let videoUrls: [URL]
  
  public init(id: String, title: String, content: String, imageUrls: [URL], url: URL?, videoUrls: [URL]) {
    self.id = id
    self.title = title
    self.content = content
    self.imageUrls = imageUrls
    self.url = url
    self.videoUrls = videoUrls
  }
  
  public init(id: String, title: String, content: String, imageUrls: [String], url: String?, videoUrls: [String]) {
    let imageURLs = imageUrls.compactMap { URL(string: $0) }
    let videoURLs = videoUrls.compactMap { URL(string: $0) }
    self.init(id: id, title: title, content: content, imageUrls: imageURLs, url: URL(string: url ?? ""), videoUrls: videoURLs)
  }
}

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
}

//
//  SceneProviding.swift
//  PovioKit
//
//  Created by Gentian Barileva on 16/07/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation

@available(iOS 14.0, *)
public protocol SceneProviding {
  func getConnectedScenes() -> [Scene]
}

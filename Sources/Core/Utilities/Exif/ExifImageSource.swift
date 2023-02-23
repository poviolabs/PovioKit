//
//  ExifImageSource.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 17/02/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation

public enum ExifImageSource {
  case url(URL)
  case data(Data)
}

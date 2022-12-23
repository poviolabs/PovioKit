//
//  File.swift
//  
//
//  Created by Borut Tomazin on 23/12/2022.
//

import AuthenticationServices
import CryptoKit
import UIKit

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    view.window ?? UIWindow()
  }
}

public extension String {
  var sha256: String {
    SHA256
      .hash(data: Data(utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}

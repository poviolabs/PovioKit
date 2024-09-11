//
//  UITextField+BuilderCompatible.swift
//  PovioKit
//
//  Created by Povio on 26/04/2019.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

extension UITextField: @preconcurrency BuilderCompatible {}

#endif

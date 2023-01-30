//
//  File.swift
//  
//
//  Created by Borut Tomazin on 30/01/2023.
//

import Foundation
import PovioKitAuthCore
import PovioKitAuthApple

class Test {
  func test() {
    let man = Manager(providers: [AppleAuthenticator()])
    man.getAuth(type: AppleAuthenticator.self)
    
//    man.getAuth(type: AppleAuthenticator.self)?.signOut()
    
//    msi
  }
}

//
//  AppDelegate.swift
//  Demo
//
//  Created by Toni Kocjan on 29/07/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.makeKeyAndVisible()
    window.rootViewController = UINavigationController(rootViewController: RootViewController())
    self.window = window
    return true
  }
}

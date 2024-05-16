// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v13), .macOS(.v13)
  ],
  products: [
    .library(
      name: "PovioKitCore",
      targets: ["PovioKitCore"]
    ),
    .library(
      name: "PovioKitUtilities", 
      targets: ["PovioKitUtilities"]
    ),
    .library(
      name: "PovioKitNetworking", 
      targets: ["PovioKitNetworking"]
    ),
    .library(
      name: "PovioKitPromise", 
      targets: ["PovioKitPromise"]
    ),
    .library(
      name: "PovioKitUIKit", 
      targets: ["PovioKitUIKit"]
    ),
    .library(
      name: "PovioKitSwiftUI", 
      targets: ["PovioKitSwiftUI"]
    ),
    .library(
      name: "PovioKitAsync", 
      targets: ["PovioKitAsync"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/Alamofire/Alamofire", 
      .upToNextMajor(from: "5.0.0")
    )
  ],
  targets: [
    .target(
      name: "PovioKitCore",
      path: "Sources/Core",
      resources: [.copy("../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitNetworking",
      dependencies: [
        "Alamofire",
        "PovioKitPromise",
      ],
      path: "Sources/Networking",
      resources: [.copy("../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitPromise",
      dependencies: [],
      path: "Sources/PromiseKit",
      resources: [.copy("../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitUIKit",
      dependencies: [
        "PovioKitCore",
        "PovioKitUtilities",
      ],
      path: "Sources/UI/UIKit",
      resources: [.copy("../../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitSwiftUI",
      dependencies: [
        "PovioKitCore",
      ],
      path: "Sources/UI/SwiftUI",
      resources: [.copy("../../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitUtilities",
      dependencies: [
        "PovioKitCore",
      ],
      path: "Sources/Utilities",
      resources: [.copy("../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitAsync",
      dependencies: [],
      path: "Sources/Async",
      resources: [.copy("../../Resources/PrivacyInfo.xcprivacy")]
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKitCore",
        "PovioKitPromise",
        "PovioKitNetworking",
        "PovioKitUIKit",
        "PovioKitSwiftUI",
        "PovioKitUtilities",
        "PovioKitAsync",
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

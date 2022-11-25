// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "PovioKit", targets: ["PovioKit"]),
    .library(name: "PovioKitNetworking", targets: ["PovioKitNetworking"]),
    .library(name: "PovioKitPromise", targets: ["PovioKitPromise"]),
    .library(name: "PovioKitUI", targets: ["PovioKitUI"]),
    .library(name: "PovioKitAuthApple", targets: ["PovioKitAuthApple"]),
    .library(name: "PovioKitAuthGoogle", targets: ["PovioKitAuthGoogle"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.6.2")),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "6.2.4")),
  ],
  targets: [
    .target(
      name: "PovioKit",
      path: "Sources/Core"
    ),
    .target(
      name: "PovioKitNetworking",
      dependencies: [
        "PovioKit",
        "Alamofire",
        "PovioKitPromise",
      ],
      path: "Sources/Networking"
    ),
    .target(
      name: "PovioKitPromise",
      dependencies: [],
      path: "Sources/PromiseKit"
    ),
    .target(
      name: "PovioKitUI",
      dependencies: [
        "PovioKit"
      ],
      path: "Sources/UI"
    ),
    .target(
      name: "PovioKitAuthCore",
      dependencies: [],
      path: "Sources/Auth/Core"
    ),
    .target(
      name: "PovioKitAuthApple",
      dependencies: [
        "PovioKitAuthCore"
      ],
      path: "Sources/Auth/Apple"
    ),
    .target(
      name: "PovioKitAuthGoogle",
      dependencies: [
        "PovioKitAuthCore",
        .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
      ],
      path: "Sources/Auth/Google"
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKit",
        "PovioKitPromise",
        "PovioKitNetworking",
        "PovioKitUI"
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

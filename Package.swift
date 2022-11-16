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
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.6.2")),
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
      name: "PovioKitAuthApple",
      dependencies: [],
      path: "Sources/Auth/Apple"
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

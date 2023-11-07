// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "PovioKitCore", targets: ["PovioKitCore"]),
    .library(name: "PovioKitNetworking", targets: ["PovioKitNetworking"]),
    .library(name: "PovioKitPromise", targets: ["PovioKitPromise"]),
    .library(name: "PovioKitUI", targets: ["PovioKitUI"]),
    .library(name: "PovioKitAsync", targets: ["PovioKitAsync"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.0.0"))
  ],
  targets: [
    .target(
      name: "PovioKitCore",
      path: "Sources/Core"
    ),
    .target(
      name: "PovioKitNetworking",
      dependencies: [
        "PovioKitCore",
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
        "PovioKitCore"
      ],
      path: "Sources/UI"
    ),
    .target(
        name: "PovioKitAsync",
        dependencies: [
        ],
        path: "Sources/Async"
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKitCore",
        "PovioKitPromise",
        "PovioKitNetworking",
        "PovioKitUI",
        "PovioKitAsync",
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

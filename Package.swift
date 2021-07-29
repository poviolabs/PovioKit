// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(name: "PovioKit", targets: ["PovioKit"]),
    .library(name: "PovioKitNetworking", targets: ["PovioKitNetworking"]),
    .library(name: "PovioKitPromise", targets: ["PovioKitPromise"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.4.0"))
  ],
  targets: [
    .target(
      name: "PovioKit",
      path: "Sources",
      exclude: [
        "Networking",
        "PromiseKit",
      ]
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
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKit",
        "PovioKitPromise",
        "PovioKitNetworking"
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

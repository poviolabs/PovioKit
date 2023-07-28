// swift-tools-version:5.8
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
    .library(name: "PovioKitUtilities", targets: ["PovioKitUtilities"])
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
      name: "PovioKitUtilities",
      dependencies: [
        "PovioKitCore"
      ],
      path: "Sources/Utilities"
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKitCore",
        "PovioKitPromise",
        "PovioKitNetworking",
        "PovioKitUI",
        "PovioKitUtilities"
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

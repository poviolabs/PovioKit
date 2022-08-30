// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_12)
  ],
  products: [
    .library(name: "PovioKit", targets: ["PovioKit"]),
    .library(name: "PovioKitNetworking", targets: ["PovioKitNetworking"]),
    .library(name: "PovioKitPromise", targets: ["PovioKitPromise"]),
    .library(name: "PovioKitUI", targets: ["PovioKitUI"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/Alamofire/Alamofire",
      .upToNextMajor(from: "5.5.0")),
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      .upToNextMajor(from: "1.9.0")),
    .package(
      url: "https://github.com/SnapKit/SnapKit.git",
      .upToNextMajor(from: "5.0.1")),
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
      dependencies: [],
      path: "Sources/UI"
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKit",
        "PovioKitPromise",
        "PovioKitNetworking",
        "PovioKitUI",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        "SnapKit",
      ],
      exclude: [
        "UI/__Snapshots__/"
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

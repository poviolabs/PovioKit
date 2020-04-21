// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v11),
    .macOS(.v10_14),
    .tvOS(.v10),
    .watchOS(.v3)
  ],
  products: [
    .library(name: "PovioKit", targets: ["PovioKit"]),
    .library(name: "PovioKitNetworking", targets: ["PovioKitNetworking"])
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("5.1.0"))
  ],
  targets: [
    .target(
      name: "PovioKit",
      path: "Sources",
      exclude: ["Networking"]
    ),
    .target(
      name: "PovioKitNetworking",
      dependencies: ["PovioKit", "Alamofire"],
      path: "Sources",
      sources: ["Networking"]
    )
  ],
  swiftLanguageVersions: [.v5]
)

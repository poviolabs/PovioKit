// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(name: "PovioKit", targets: ["PovioKit"]),
    .library(name: "PovioKitNetworking", targets: ["PovioKitNetworking"])
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.4.1"))
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
      path: "Sources/Networking"
    )
  ],
  swiftLanguageVersions: [.v5]
)

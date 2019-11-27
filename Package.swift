// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .macOS(.v10_14), .iOS(.v11), .tvOS(.v10), .watchOS(.v3)
  ],
  products: [
    .library(name: "PovioKit", targets: ["PovioKit"])
  ],
  targets: [
    .target(name: "PovioKit", path: "PovioKit")
  ],
  swiftLanguageVersions: [.v5]
)

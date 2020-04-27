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
    .library(name: "PovioKit", targets: ["PovioKit"])
  ],
  targets: [
    .target(
      name: "PovioKit",
      path: "Sources",
      exclude: ["Networking"]
    )
  ],
  swiftLanguageVersions: [.v5]
)

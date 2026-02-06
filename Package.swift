// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LocalStorageKit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "LocalStorageKit",
      targets: ["LocalStorageKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    .package(url: "https://github.com/nts-sixblack/SwiftInjected.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "LocalStorageKit",
      dependencies: ["KeychainAccess", "SwiftInjected"],
      path: "Sources"
    ),
    .testTarget(
      name: "LocalStorageKitTests",
      dependencies: ["LocalStorageKit"],
      path: "Tests"
    ),
  ]
)

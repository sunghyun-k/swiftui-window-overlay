// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "swiftui-window-overlay",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "WindowOverlay",
      targets: ["WindowOverlay"]),
  ],
  targets: [
    .target(
      name: "WindowOverlay"),
  ]
)

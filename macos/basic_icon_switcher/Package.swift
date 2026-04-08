// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "basic_icon_switcher",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "basic-icon-switcher", targets: ["basic_icon_switcher"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "basic_icon_switcher",
            dependencies: []
        )
    ]
)

// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swiftui-launcher-window",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "LauncherWindow", targets: ["LauncherWindow"])
    ],
    dependencies: [
		.package(url: "https://github.com/astzweig/swiftui-frameless-window", from: "2.1.0")
    ],
    targets: [
        .target(name: "LauncherWindow", dependencies: [
            .product(name: "FramelessWindow", package: "swiftui-frameless-window")
        ]),
		.executableTarget(name: "TestApp", dependencies: ["LauncherWindow"])
    ]
)

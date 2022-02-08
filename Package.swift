// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ThemeSite",
    products: [
        .executable(
            name: "ThemeSite",
            targets: ["ThemeSite"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0")
    ],
    targets: [
        .target(
            name: "ThemeSite",
            dependencies: ["Publish"]
        )
    ]
)
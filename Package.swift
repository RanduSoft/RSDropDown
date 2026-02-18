// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "RSDropDown",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RSDropDown", targets: ["RSDropDown"]),
    ],
    targets: [
        .target(
            name: "RSDropDown",
            path: "Sources"
        ),
        .testTarget(
            name: "RSDropDownTests",
            dependencies: ["RSDropDown"],
            path: "Tests"
        )
    ]
)

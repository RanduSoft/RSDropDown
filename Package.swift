// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "RSDropDown",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RSDropDown", targets: ["RSDropDown"]),
        .library(name: "RSDropDownDemo", targets: ["RSDropDownDemo"])
    ],
    targets: [
        .target(
            name: "RSDropDown",
            path: "Sources"
        ),
        .target(
            name: "RSDropDownDemo",
            dependencies: ["RSDropDown"],
            path: "Demo"
        ),
        .testTarget(
            name: "RSDropDownTests",
            dependencies: ["RSDropDown"],
            path: "Tests"
        )
    ]
)

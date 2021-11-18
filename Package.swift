// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RSDropDown",
	platforms: [.iOS(.v13)],
    products: [
        .library(name: "RSDropDown", targets: ["RSDropDown"])
    ],
    targets: [
		.target(
			name: "RSDropDown",
			path: "Files"
		)
    ]
)

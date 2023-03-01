// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporToOpenAPI",
		products: [
			.library(name: "VaporToOpenAPI", targets: ["VaporToOpenAPI"]),
		],
		dependencies: [
			// 💧 A server-side Swift web framework.
			.package(url: "https://github.com/vapor/vapor.git", from: "4.67.4"),
			.package(url: "https://github.com/dankinsoid/SwiftToOpenAPI", from: "0.7.0"),
		],
    targets: [
			.target(
				name: "VaporToOpenAPI",
				dependencies: [
					.product(name: "Vapor", package: "vapor"),
					.product(name: "SwiftToOpenAPI", package: "SwiftToOpenAPI")
				]
			),
			.testTarget(
				name: "VaporToOpenAPITests",
				dependencies: ["VaporToOpenAPI"]
			),
    ]
)

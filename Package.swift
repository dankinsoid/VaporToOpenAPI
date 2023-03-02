// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporToOpenAPI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
		products: [
			.library(name: "VaporToOpenAPI", targets: ["VaporToOpenAPI"]),
		],
		dependencies: [
			// 💧 A server-side Swift web framework.
			.package(url: "https://github.com/vapor/vapor.git", from: "4.70.0"),
			.package(url: "https://github.com/dankinsoid/SwiftOpenAPI", from: "1.2.0"),
		],
    targets: [
			.target(
				name: "VaporToOpenAPI",
				dependencies: [
					.product(name: "Vapor", package: "vapor"),
					.product(name: "SwiftOpenAPI", package: "SwiftOpenAPI")
				]
			),
			.testTarget(
				name: "VaporToOpenAPITests",
				dependencies: ["VaporToOpenAPI"]
			),
    ]
)

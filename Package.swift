// swift-tools-version:5.5
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
			.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
			.package(url: "https://github.com/dankinsoid/VDCodable", from: "2.8.0"),
			.package(url: "https://github.com/dankinsoid/Swiftgger.git", from: "2.0.13")
		],
    targets: [
			.target(
				name: "VaporToOpenAPI",
				dependencies: [
					.product(name: "Vapor", package: "vapor"),
					.product(name: "Swiftgger", package: "Swiftgger"),
					.product(name: "VDCodable", package: "VDCodable")
				]
			),
			.testTarget(
				name: "VaporToOpenAPITests",
				dependencies: ["VaporToOpenAPI"]
			),
    ]
)

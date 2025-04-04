// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "VaporToOpenAPI",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		.library(name: "VaporToOpenAPI", targets: ["VaporToOpenAPI"]),
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
		.package(url: "https://github.com/dankinsoid/SwiftOpenAPI.git", from: "2.24.1"),
	],
	targets: [
		.target(
			name: "VaporToOpenAPI",
			dependencies: [
				.product(name: "Vapor", package: "vapor"),
				.product(name: "SwiftOpenAPI", package: "SwiftOpenAPI"),
			]
		),
		.testTarget(
			name: "VaporToOpenAPITests",
			dependencies: [
				"VaporToOpenAPI",
			]
		),
	]
)

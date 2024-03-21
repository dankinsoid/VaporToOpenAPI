// swift-tools-version:5.7
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
		.package(url: "https://github.com/dankinsoid/SwiftOpenAPI.git", from: "2.20.0"),
		.package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "0.10.3"),
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
				.product(name: "CustomDump", package: "swift-custom-dump"),
			]
		),
	]
)

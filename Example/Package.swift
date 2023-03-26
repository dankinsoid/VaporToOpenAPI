// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "Petstore",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.executable(name: "Run", targets: ["Run"]),
		.library(name: "Petstore", targets: ["App"]),
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "4.70.0"),
		.package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "3.10.0"),
	],
	targets: [
		.target(
			name: "App",
			dependencies: [
				.product(name: "Vapor", package: "vapor"),
				.product(name: "VaporToOpenAPI", package: "VaporToOpenAPI"),
			]
		),
		.executableTarget(
			name: "Run",
			dependencies: [.target(name: "App")]
		),
	]
)

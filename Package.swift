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
			.package(url: "https://github.com/mczachurski/Swiftgger.git", from: "1.4.0")
		],
    targets: [
			.target(
				name: "VaporToOpenAPI",
				dependencies: [
					.product(name: "Vapor", package: "vapor"),
					.product(name: "Swiftgger", package: "swiftgger")
				],
				swiftSettings: [
					// Enable better optimizations when building in Release configuration. Despite the use of
					// the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
					// builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
					.unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
				]
			),
			.testTarget(
				name: "VaporToOpenAPITests",
				dependencies: ["VaporToOpenAPI"]
			),
    ]
)

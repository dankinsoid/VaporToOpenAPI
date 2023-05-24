import Foundation
import Logging
import SwiftOpenAPI
import Vapor

/// configures your application
public func configure(_ app: Application) async throws {

	app.logger.info("Environment: \(app.environment.name)")
	app.logger.info("Log level: \(app.logger.logLevel)")

	// middlewares

	app.middleware.use(
		FileMiddleware(
			publicDirectory: app.directory.publicDirectory,
			defaultFile: "index.html"
		)
	)

//	app.views.use(.leaf)

	DateEncodingFormat.default = .dateTime

	// register routes
	try app.register(collection: OpenAPIController())
	try app.register(collection: PetController())
	try app.register(collection: StoreController())
	try app.register(collection: UserController())

	let encoder = JSONEncoder()
	encoder.outputFormatting = .sortedKeys
	ContentConfiguration.global.use(encoder: encoder, for: .json)
}

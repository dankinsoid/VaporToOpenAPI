import Vapor

public extension RoutesBuilder {

	/// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
	/// - Parameters:
	///   - path: The path to the stoplight documentation.
	///   - title: The title of the OpenAPI documentation page.
	///   - options: The options of the OpenAPI documentation page. [Documentation](https://docs.stoplight.io/docs/elements/b074dc47b2826-elements-configuration-options)
	///   - openAPI: A closure that returns the OpenAPI documentation.
	@discardableResult
	func stoplightDocumentation(
		_ path: PathComponent...,
		title: String = "OpenAPI Documentation",
		options: StoplightElementsOptions = StoplightElementsOptions(),
		openAPI: @escaping (Routes) throws -> OpenAPIObject
	) -> Route {
		stoplightDocumentation(path, title: title, options: options, openAPI: openAPI)
	}

	/// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
	/// - Parameters:
	///   - path: The path to the stoplight documentation.
	///   - title: The title of the OpenAPI documentation page.
	///   - options: The options of the OpenAPI documentation page. [Documentation](https://docs.stoplight.io/docs/elements/b074dc47b2826-elements-configuration-options)
	///   - openAPI: A closure that returns the OpenAPI documentation.
	@discardableResult
	func stoplightDocumentation(
		_ path: [PathComponent],
		title: String = "OpenAPI Documentation",
		options: StoplightElementsOptions = StoplightElementsOptions(),
		openAPI: @escaping (Routes) throws -> OpenAPIObject
	) -> Route {
		let jsonPath = path + ["openapi.json"]
		get(jsonPath) { req in
			try openAPI(req.application.routes)
		}
		.excludeFromOpenAPI()

		return stoplightDocumentation(
			path,
			openAPIPath: "/" + jsonPath.string,
			title: title,
			options: options
		)
	}

	/// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
	/// - Parameters:
	///   - path: The path to the stoplight documentation.
	///   - openAPIPath: The path to the OpenAPI documentation.
	///   - title: The title of the OpenAPI documentation page.
	///   - options: The options of the OpenAPI documentation page. [Documentation](https://docs.stoplight.io/docs/elements/b074dc47b2826-elements-configuration-options)
	@discardableResult
	func stoplightDocumentation(
		_ path: PathComponent...,
		openAPIPath: String,
		title: String = "OpenAPI Documentation",
		options: StoplightElementsOptions = StoplightElementsOptions()
	) -> Route {
		stoplightDocumentation(path, openAPIPath: openAPIPath, title: title, options: options)
	}

	/// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
	/// - Parameters:
	///   - path: The path to the stoplight documentation.
	///   - openAPIPath: The path to the OpenAPI documentation.
	///   - title: The title of the OpenAPI documentation page.
	///   - options: The options of the OpenAPI documentation page. [Documentation](https://docs.stoplight.io/docs/elements/b074dc47b2826-elements-configuration-options)
	@discardableResult
	func stoplightDocumentation(
		_ path: [PathComponent],
		openAPIPath: String,
		title: String = "OpenAPI Documentation",
		options: StoplightElementsOptions = StoplightElementsOptions()
	) -> Route {
		get(path) { _ in
			var headers = HTTPHeaders()
			headers.contentType = .html

			return Response(
				status: .ok,
				headers: headers,
				body: .init(string: """
				<!doctype html>
				<html lang="en" data-theme="\(options.theme.rawValue)">

				<head>
				  <meta charset="utf-8">
				  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
				  <title>\(title)</title>

				  <script src="https://unpkg.com/@stoplight/elements/web-components.min.js"></script>
				  <link rel="stylesheet" href="\(options.cssLink)">
				</head>

				<body>
				  <elements-api 
				    apiDescriptionUrl="\(openAPIPath)"
				    router="\(options.router.rawValue)"
				    layout="\(options.layout.rawValue)"
				    hideInternal="\(options.hideInternal)"
				    hideTryIt="\(options.hideTryIt)"
				    hideSchemas="\(options.hideSchemas)"
				    hideExport="\(options.hideExport)"
				    tryItCredentialsPolicy="\(options.tryItCredentialsPolicy.rawValue)"
				    "\(options.tryItCorsProxy.map { "tryItCorsProxy=\"\($0)\"" } ?? "")"
				    "\(options.logo.map { "logo=\"\($0)\"" } ?? "")"
				  />
				</body>

				</html>
				""")
			)
		}
		.excludeFromOpenAPI()
	}
}

public struct StoplightElementsOptions: Hashable, Codable, Sendable {

	public var theme: Theme
	public var layout: Layout
	public var router: Router
	public var cssLink: String
	public var logo: String?
	public var hideInternal: Bool
	public var hideTryIt: Bool
	public var hideSchemas: Bool
	public var hideExport: Bool
	public var tryItCorsProxy: String?
	public var tryItCredentialsPolicy: TryItCredentialsPolicy

	public init(
		theme: Theme = .light,
		layout: Layout = .sidebar,
		router: Router = .hash,
		cssLink: String = "https://unpkg.com/@stoplight/elements/styles.min.css",
		logo: String? = nil,
		hideInternal: Bool = false,
		hideTryIt: Bool = false,
		hideSchemas: Bool = false,
		hideExport: Bool = false,
		tryItCorsProxy: String? = nil,
		tryItCredentialsPolicy: TryItCredentialsPolicy = .omit
	) {
		self.theme = theme
		self.layout = layout
		self.cssLink = cssLink
		self.logo = logo
		self.router = router
		self.hideInternal = hideInternal
		self.hideTryIt = hideTryIt
		self.hideSchemas = hideSchemas
		self.hideExport = hideExport
		self.tryItCorsProxy = tryItCorsProxy
		self.tryItCredentialsPolicy = tryItCredentialsPolicy
	}

	public enum Theme: String, Codable {
		case dark, light
	}

	public enum Layout: String, Codable {
		case sidebar, responsive, stacked
	}

	public enum Router: String, Codable {
		case history, hash, memory, `static`
	}

	public enum TryItCredentialsPolicy: String, Codable {
		case omit, include, sameOrigin = "same-origin"
	}
}

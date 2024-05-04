import Vapor

extension RoutesBuilder {

    /// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
    /// - Parameters:
    ///   - path: The path to the stoplight documentation.
    ///   - title: The title of the OpenAPI documentation page.
    ///   - openAPI: A closure that returns the OpenAPI documentation.
    @discardableResult
    public func stoplightDocumentation(
        _ path: PathComponent...,
        title: String = "OpenAPI Documentation",
        openAPI: @escaping (Routes) throws -> OpenAPIObject
    ) -> Route {
        stoplightDocumentation(path, title: title, openAPI: openAPI)
    }

    /// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
    /// - Parameters:
    ///   - path: The path to the stoplight documentation.
    ///   - title: The title of the OpenAPI documentation page.
    ///   - openAPI: A closure that returns the OpenAPI documentation.
    @discardableResult
    public func stoplightDocumentation(
        _ path: [PathComponent],
        title: String = "OpenAPI Documentation",
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
            title: title
        )
    }

    /// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
    /// - Parameters:
    ///   - path: The path to the stoplight documentation.
    ///   - openAPIPath: The path to the OpenAPI documentation.
    ///   - title: The title of the OpenAPI documentation page.
    @discardableResult
    public func stoplightDocumentation(
        _ path: PathComponent...,
        openAPIPath: String,
        title: String = "OpenAPI Documentation"
    ) -> Route {
        stoplightDocumentation(path, openAPIPath: openAPIPath, title: title)
    }

    /// Registers an OpenAPI documentation page using the [Stoplight Elements API](https://stoplight.io/).
    /// - Parameters:
    ///   - path: The path to the stoplight documentation.
    ///   - openAPIPath: The path to the OpenAPI documentation.
    ///   - title: The title of the OpenAPI documentation page.
    @discardableResult
    public func stoplightDocumentation(
        _ path: [PathComponent],
        openAPIPath: String,
        title: String = "OpenAPI Documentation"
    ) -> Route {
        get(path) { req in
            var headers = HTTPHeaders()
            headers.contentType = .html
            
            return Response(
                status: .ok,
                headers: headers,
                body: .init(string: """
                <!doctype html>
                <html lang="en">

                <head>
                  <meta charset="utf-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
                  <title>\(title)</title>

                  <script src="https://unpkg.com/@stoplight/elements/web-components.min.js"></script>
                  <link rel="stylesheet" href="https://unpkg.com/@stoplight/elements/styles.min.css">
                </head>

                <body>
                  <elements-api apiDescriptionUrl="\(openAPIPath)" router="hash" />
                </body>

                </html>
                """)
            )
        }
        .excludeFromOpenAPI()
    }
}

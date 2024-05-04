import Vapor

extension RoutesBuilder {
    public func registerOpenAPIElements(path: String, title: String = "OpenAPI Documentation") {
        get("") { req in
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
                  <elements-api apiDescriptionUrl="\(path)" router="hash" />
                </body>

                </html>
                """)
            )
        }
        .excludeFromOpenAPI()
    }
}

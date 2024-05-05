# VaporToOpenAPI

[![build](https://github.com/dankinsoid/VaporToOpenAPI/actions/workflows/test.yml/badge.svg)](https://github.com/dankinsoid/VaporToOpenAPI/actions/workflows/test.yml)

VaporToOpenAPI is a Swift library which can generate output compatible with [OpenAPI version 3.0.1](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md) from Vapor code. You can use generated file in [Swagger UI](https://swagger.io/swagger-ui/) or [Stoplight](https://stoplight.io).\
The library is based on [SwiftOpenAPI](https://github.com/dankinsoid/SwiftOpenAPI).

## Usage

### [Stoplight](https://stoplight.io) setup
1. Describe all of your routes and register all controllers as described in [Vapor docs](https://docs.vapor.codes/basics/routing). Add OpenAPI details to each route using the `route.openAPI` method.
2. Add a route  via the `routes.stoplightDocumentation` to return an `OpenAPIObject` instance via the `routes.openAPI` method.

### [Swagger](https://swagger.io) setup
1. Set up a [SwaggerUI page](https://github.com/swagger-api/swagger-ui) in your Vapor project downloading the `dist` folder and placing its content in the `Public/Swagger` directory.
2. Describe all of your routes and register all controllers as described in [Vapor docs](https://docs.vapor.codes/basics/routing). Add OpenAPI details to each route using the `route.openAPI` method.
3. Add a route to return a [SwaggerUI index.html](https://github.com/swagger-api/swagger-ui/blob/master/dist/index.html). Or configure your middlewares to use 'index.html' as default page.
4. Add a route to return an `OpenAPIObject` instance via the `app.routes.openAPI` method. Make sure the path of this route matches the `swagger.json` URL in your SwaggerUI page method.

⚠️ All enums in your models must implement `CaseIterable`.

### Advanced Usage
VaporToOpenAPI includes several advanced features that allow you to customize the generated OpenAPI documentation in various ways. Some of these features include:

- `openAPI`: This method is used to add OpenAPI metadata to a single Vapor route. It takes a variety of parameters, such as a summary and description of the operation, request and response bodies, query parameters, and more.\
Here's an example of how you might use it to document a POST request:
```swift
routes.post("users") { req -> EventLoopFuture<User> in
    let user = try req.content.decode(User.self)
    return user.save(on: req.db).map { user }
}
.openAPI(
    summary: "Create User",
    description: "Create a new user with the provided data",
    body: .type(User.self),
    response: .type(User.self)
)
```
- `openAPI` (on Routes): This method is used to generate an entire OpenAPI specification from your Vapor routes. It takes a variety of parameters, such as the title and description of your API, the available paths and operations, security requirements, and more.
```swift
// generate OpenAPI documentation
routes.get("Swagger", "swagger.json") { req in
  req.application.routes.openAPI(
    info: InfoObject(
      title: "Example API",
      description: "Example API description",
      version: "0.1.0",
    )
  )
}
.excludeFromOpenAPI()
```
- `response`: This method is used to specify an additional response body for a Vapor route. It takes a variety of parameters, such as the status code, description, and response body type.
- `groupedOpenAPI`: These methods are used to group Vapor routes together based on OpenAPI metadata, such as tags or security requirements.\
Here's an example of how you might use it to group routes with the same security requirements:
```swift
let routes = app.routes.groupedOpenAPI(auth: .apiKey())
```
- `groupedOpenAPIResponse`: These methods are used to group Vapor routes together based on common response.

- `groupedOpenAPI(server:)`: These methods are used to group Vapor routes together based on common servers.

- `excludeFromOpenAPI`: This method is used to exclude a Vapor route from the generated OpenAPI specification.
   
- `openAPINoAuth`: This method is used to specify that an operation does not require any authentication.
   
- `openAPI(custom:)`: These methods are used to customize a specific aspect of the OpenAPI metadata for a Vapor route, such as a specific security scheme or callback.

- `stoplightDocumentation(openAPI:)`: These methods are used to generate a [Stoplight documentation](https://stoplight.io/) from your Vapor routes.

- `operationID` and `operationRef`: These properties are used to generate unique identifiers for OpenAPI operations and to create references to them in other parts of the specification.

#### Customizing OpenAPI schemas and parameters
You can customize OpenAPI schemas and parameters result by implementing `OpenAPIDescriptable` and `OpenAPIType` protocols.
1. `OpenAPIDescriptable` protocol allows you to provide a custom description for the type and its properties. `@OpenAPIDescriptable` macro implements this protocol with your comments.
```swift
import SwiftOpenAPI

@OpenAPIDescriptable
/// Login request body.
struct LoginBody: Codable {
    
    /// Username string.
    let username: String
    /// Password string. Encoded.
    let password: String
}
```
Manually:
```swift
struct LoginBody: Codable, OpenAPIDescriptable {
    
    let username: String
    let password: String
    
    static var openAPIDescription: OpenAPIDescriptionType? {
        OpenAPIDescription<CodingKeys>("Login request body.")
            .add(for: .username, "Username string.")
            .add(for: .password, "Password string. Encoded.")
    }
}
```
2. `OpenAPIType` protocol allows you to provide a custom schema for the type.
```swift
import SwiftOpenAPI

struct Color: Codable, OpenAPIType {
    
    static var openAPISchema: SchemaObject {
        .string(format: "hex", description: "Color in hex format")
    }
}
```

#### Links
Links are one of the new features of OpenAPI 3.0. Using links, you can describe how various values returned by one operation can be used as input for other operations.
To create a Link:
1. create `LinkKey` type identifying some reusable parameter.
2. specify the type in each route using the related parameter

```swift
enum PetID: LinkKey {
}
```
```swift
route.get("pet", use: getPet).openAPI(
  links: [
    Link(\Pet.id, in: .response): PetID.self
  ]
)

route.post("pet", ":petID", use: renamePer).openAPI(
  links: [
    Link("petID", in: .path): PetID.self
  ]
)
```

## [Example project](Example/)
## Short example
### 1. SwaggerUI page
Change `url` in [`swagger-initializer.js`](https://github.com/swagger-api/swagger-ui/blob/master/dist/swagger-initializer.js)
```js
window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">

  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  var jsonURL = document.location.origin + "/Swagger/swagger.json";
  window.ui = SwaggerUIBundle({
    url: jsonURL,
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  });

  //</editor-fold>
};
```
### 2. Routes
```swift
routes = routes
  .groupedOpenAPI(auth: .basic)
  .groupedOpenAPIResponse(
    statusCode: 400,
    body: .type(of: ErrorResponse())
  )

routes.post("login") { req in
  try await loginService.makeLoginRequest(
    query: req.query.decode(LoginQuery.self),
    content: req.content.decode(LoginRequestBody.self)
  )
}
.openAPI(
  summary: "Login",
  description: "Login request",
  query: .type(LoginQuery.self),
  headers: ["X-SOME_VALUE": .string],
  body: .type(LoginRequestBody.self),
  response: .type(LoginResponse.self),
  auth: .apiKey()
)
```
### 3. SwaggerUI page routing
```swift
FileMiddleware(publicDirectory: app.directory.publicDirectory, defaultFile: "index.html")
```
### 4. OpenAPIObject route
```swift
// generate OpenAPI documentation
routes.get("Swagger", "swagger.json") { req in
  req.application.routes.openAPI(
    info: InfoObject(
      title: "Example API",
      description: "Example API description",
      version: "0.1.0",
    )
  )
}
.excludeFromOpenAPI()
```

## Installation
1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "4.6.6")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["VaporToOpenAPI"])
  ]
)
```
```ruby
$ swift build
```

## Contributing
Contributions to VaporToOpenAPI are welcome! If you find a bug or have a feature request, please raise an issue or submit

## Author

dankinsoid, voidilov@gmail.com

## License

VaporToOpenAPI is available under the MIT license. See the LICENSE file for more info.


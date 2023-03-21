# VaporToOpenAPI

VaporToOpenAPI is a Swift library which can generate output compatible with [OpenAPI version 3.0.1](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md) from Vapor code. You can use generated file in [Swagger UI](https://swagger.io/swagger-ui/).

## Usage
1. Set up a [SwaggerUI page](https://github.com/swagger-api/swagger-ui) in your Vapor project downloading the `dist` folder and placing its content in the `Public/Swagger` directory.
2. Describe all of your routes and register all controllers as described in [Vapor docs](https://docs.vapor.codes/basics/routing). Optionally, add OpenAPI details to each route using the `route.openAPI` method.
3. Add a route to return a [SwaggerUI index.html](https://github.com/swagger-api/swagger-ui/blob/master/dist/index.html). Or configure your middlewares to use 'index.html' as default page.
4. Add a route to return an `OpenAPIObject` instance via the `app.routes.openAPI` method. Make sure the path of this route matches the "swagger.json" URL in your SwaggerUI page method.

All models should implement `WithExample` protocol, all enums must implement `CaseIterable`.
## Example
### 1. SwaggerUI page
Change `url` in [`swagger-initializer.js`](https://github.com/swagger-api/swagger-ui/blob/master/dist/swagger-initializer.js)
```js
window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">

  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  window.ui = SwaggerUIBundle({
    url: "./Swagger/swagger.json",
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
routes = routes.groupedOpenAPI(auth: .basic)

routes.post("login") { req in
  try await loginService.makeLoginRequest(
    query: req.query.decode(LoginQuery.self),
    content: req.content.decode(LoginRequestBody.self)
  )
}
.openAPI(
  summary: "Login",
  description: "Login request",
  query: LoginQuery.example,
  body: LoginRequestBody.example,
  response: LoginResponse.example,
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
    ),
    errorExamples: [400: ErrorResponse()]
  )
}
.excludeFromOpenAPI()
```

## Links
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

## Installation
1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "2.0.2")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["VaporToOpenAPI"])
  ]
)
```
```ruby
$ swift build
```

## Author

dankinsoid, voidilov@gmail.com

## License

VaporToOpenAPI is available under the MIT license. See the LICENSE file for more info.


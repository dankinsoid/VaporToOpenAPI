# VaporToOpenAPI

VaporToOpenAPI is a Swift library which can generate output compatible with [OpenAPI version 3.0.1](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md) from Vapor code. You can use generated file in [Swagger UI](https://swagger.io/swagger-ui/).

## Usage
1. Describe all routes and register all controllers as described in [Vapor docs](https://docs.vapor.codes/basics/routing)
   - Add OpenAPI details to each route via [`route.openAPI` method](#1-routes). (optional)
2. Create an `OpenAPIDocument` instance via [`app.routes.openAPI`](#2-openapidocument) method.
3. Convert the `OpenAPIDocument` to json or yml file.
   - `OpenAPIDocument` conforms to the `Codable` protocol so `JSONEncoder` can be used for this purpose.
4. Save the file into a SwuggerUI folder.
5. Add a route to [SwaggerUI page](https://swagger.io/swagger-ui/).

## Example
### 1. Routes
```swift
routes.post("login") { req in
  try await loginService.makeLoginRequest(
    query: req.query.decode(LoginQuery.self),
    content: req.content.decode(LoginRequestBody.self)
  )
}
.openAPI(
  summary: "Login",
  description: "Login request",
  response: LoginResponse.self,
  content: LoginRequestBody.self,
  query: LoginQuery.self,
  headers: AuthHeaders.self
)

routes.get("api") { req in
  req.view.render("swagger")
}
.excludeFromOpenAPI()
```
### 2. OpenAPIDocument
```swift
let api = app.routes.openAPI(
  title: "Example API",
  version: "0.1.0",
  description: "Example API description",
  objects: [
    // Add an additional object
    APIObject(object: ErrorResponse.example)
  ],
  map: {
    // Add an error response example to each request
    var array = $0.responses
    let failure = APIResponse(
      code: "400",
      description: ErrorResponse.example.reason,
      type: APIBodyType(
        type: ErrorResponse.self,
        example: ErrorResponse.example
      )
    )
    array.append(failure)
    return $0.set(\.responses, to: array)
    }
)
```
### 3. Saving OpenAPI
```swift
let json = try VDJSONEncoder().encode(api)
  try? FileManager.default.createDirectory(
    at: URL(fileURLWithPath: app.directory.publicDirectory + "Swagger"),
		withIntermediateDirectories: true,
		attributes: nil
  )
  // save file to Swagger directory containing SwaggerUI resources
  let url = URL(fileURLWithPath: app.directory.publicDirectory + "Swagger/swagger.json")
  try json.write(to: url)
```

## Installation
1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "0.29.0")
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


# VaporToOpenAPI

VaporToOpenAPI is a Swift library which can generate output compatible with [OpenAPI version 3.0.1](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md) from Vapor code. You can use generated file in [Swagger UI](https://swagger.io/swagger-ui/).

## Description
This repository provides a declarative way to layout in SwiftUI-style
 
## Installation
1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "0.27.0")
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


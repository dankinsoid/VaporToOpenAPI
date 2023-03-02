import XCTest
import Vapor
import SwiftOpenAPI
@testable import VaporToOpenAPI

final class VDTests: XCTestCase {
    
    func tests() throws {
        let routes = Routes()
        routes
            .get("pets") { _ -> [Pet] in
                []
            }
            .openAPI(
                tags: nil,
                summary: nil,
                description: "Get all pets",
                externalDocs: nil,
                operationId: nil,
                query: PetQuery.self,
                response: [Pet].self,
                errorResponses: [:],
                callbacks: nil,
                deprecated: nil,
                security: nil,
                servers: nil
            )
        
        
        let api = routes.openAPI(
            info: InfoObject(
                title: "Pets API",
                version: Version(1, 0, 0)
            ),
            errorResponses: [401: ErrorResponse.self]
        )
        
        try prettyPrint(api)
    }
    
    static var allTests = [
        ("tests", tests),
    ]
}

struct Pet: WithExample, Content {
    
    var name: String
    var age: UInt
    
    static let example = Pet(name: "Persey", age: 2)
}

struct PetQuery: WithExample {
    
    var filter: String?
    
    static let example = PetQuery(filter: "age>5")
}

struct ErrorResponse: WithExample {
    
    var reason: String
    var code: Int
    
    static var example = ErrorResponse(reason: "Not found", code: 401)
}

private func prettyPrint(_ codable: some Encodable) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    try print(
        String(
            data: encoder.encode(codable),
            encoding: .utf8
        ) ?? ""
    )
}

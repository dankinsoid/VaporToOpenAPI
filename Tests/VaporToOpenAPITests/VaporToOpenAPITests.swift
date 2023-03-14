import XCTest
import Vapor
import SwiftOpenAPI
@testable import VaporToOpenAPI

final class VDTests: XCTestCase {
    
    func tests() throws {
        let routes = Routes()
        routes
            .groupedOpenAPI(auth: .basic, .apiKey())
            .get("pets") { _ -> [Pet] in
                []
            }
            .openAPI(
                summary: nil,
                description: "Get all pets",
                externalDocs: nil,
                query: PetQuery.self,
                response: [Pet].self,
                errorResponses: [:],
                callbacks: nil,
                deprecated: nil,
                servers: nil
            )
        
        
        let api = routes.openAPI(
            info: InfoObject(
                title: "Pets API",
                version: Version(1, 0, 0)
            ),
            errorExamples: [401: ErrorResponse.example]
        )
        
        prettyPrint(api)
    }
    
    func testIssue1() {
        let authenticated = Routes()
        
        let groups = authenticated.grouped("groups")
        
        groups.get { _ in [GroupDTO]() }
            .openAPI(
                summary: "List \(Group.self)s",
                description: "List all the \(Group.self)s of the current \(Account.self)",
                response: [GroupDTO].self
            )
        
        groups.get("blublublu") { _ in [GroupDTO]() }
            .openAPI(
                summary: "List \(Group.self)s",
                description: "List all the \(Group.self)s of the current \(Account.self)",
                response: [GroupDTO].self
            )
        
        groups.get(":id") { _ in GroupDTO() }
            .openAPI(
                summary: "Get a \(Group.self) details",
                description: "Get details for a specific \(Group.self)s in the current \(Account.self)",
                response: GroupDTO.self,
                errorResponses: [
                    404: ErrorResponse(error: true, reason: "Not found")
                ]
            )
        
        groups.post { _ in GroupDTO() }
            .openAPI(
                summary: "Create a \(Group.self)",
                description: "Create a new users \(Group.self) in the current \(Account.self)",
                body: CreateGroup.self,
                response: GroupDTO.self,
                errorResponses: [
                    422: ErrorResponse(error: true, reason: "Error details"),
                    409: ErrorResponse(error: true, reason: "Already exists")
                ]
            )
        
        groups.put(":id") { _ in GroupDTO() }
            .openAPI(
                summary: "Update a \(Group.self)",
                description: "Update a \(Group.self) in the current \(Account.self)",
                body: CreateGroup.self,
                response: GroupDTO.self
                //responses: []
            )
        
        let api = authenticated.openAPI(
            info: InfoObject(title: "Some API", version: "1.0.0")
        )
        XCTAssertEqual(authenticated.all.count, api.paths?.value.values.flatMap { $0.object?.operations ?? [:] }.count ?? 0)
    }
    
    static var allTests = [
        ("tests", tests),
    ]
}

struct Group: WithExample, Content {
    
    static var example = Group()
    
    var id = UUID()
    var someValue = "Value"
    var accounts: [Account] = [Account()]
}

struct Account: WithExample, Content {
    
    static var example = Account()
    
    var id = UUID()
    var name = "Name"
}

struct CreateGroup: WithExample, Content {
    
    static var example = Self()
    
    var count = 10
}

struct ErrorResponse: Codable, WithExample {
    
    static var example = ErrorResponse()
    
    var error = true
    var reason = "Error"
}

struct GroupDTO: WithExample, Content {
    
    static var example = Self()
    
    var id = UUID()
    var description = "GroupDTO"
}


struct Pet: WithExample, Content {
    
    var id = UUID()
    var name: String
    var age: UInt
    
    static let example = Pet(name: "Persey", age: 2)
}

struct PetQuery: WithExample {
    
    var filter: String?
    
    static let example = PetQuery(filter: "age>5")
}

private func prettyPrint(_ codable: some Encodable) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        try print(
            String(
                data: encoder.encode(codable),
                encoding: .utf8
            ) ?? ""
        )
    } catch {
        print(codable)
    }
}

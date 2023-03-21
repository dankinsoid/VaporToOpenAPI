import Foundation
import Vapor
import SwiftOpenAPI

func response(
    _ type: Codable,
    description: String,
    contentType: MediaType,
    headers: [Codable],
    schemas: inout [String: ReferenceOr<SchemaObject>]
) throws -> ResponseObject {
    try ResponseObject(
        description: description,
        headers: Dictionary(
            headers.flatMap {
                try [String: ReferenceOr<HeaderObject>].encode($0, schemas: &schemas)
            }
        ) { _, s in s }.nilIfEmpty,
        content: [
            contentType: .encode(type, schemas: &schemas)
        ]
    )
}

func responses(
    default defaultResponse: Codable?,
    type: MediaType,
    headers: [Codable],
    errors errorResponses: [Int: Codable],
    errorType: MediaType,
    errorHeaders: [Codable],
    schemas: inout [String: ReferenceOr<SchemaObject>]
) -> ResponsesObject? {
    var responses: [ResponsesObject.Key: ResponsesObject.Value] = Dictionary(
        errorResponses.compactMap {
            try? (
                ResponsesObject.Key.code($0.key),
                .value(
                    response(
                        $0.value,
                        description: Abort(HTTPResponseStatus(statusCode: $0.key)).reason,
                        contentType: errorType,
                        headers: errorHeaders,
                        schemas: &schemas
                    )
                )
            )
        }
    ) { _, new in new }
    if let defaultResponse {
        responses[200] = try? .value(
            response(
                defaultResponse,
                description: "Success",
                contentType: type,
                headers: headers,
                schemas: &schemas
            )
        )
    }
    guard !responses.isEmpty else { return nil }
    return ResponsesObject(responses)
}

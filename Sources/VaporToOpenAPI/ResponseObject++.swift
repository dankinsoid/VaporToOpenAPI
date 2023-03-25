import Foundation
import Vapor
import SwiftOpenAPI

func response(
    _ type: Codable,
    description: String,
    contentTypes: [MediaType],
    headers: [Codable],
    schemas: inout [String: ReferenceOr<SchemaObject>]
) throws -> ResponseObject {
	let object = try MediaTypeObject.encode(type, schemas: &schemas)
	return try ResponseObject(
        description: description,
        headers: Dictionary(
            headers.flatMap {
                try [String: ReferenceOr<HeaderObject>].encode($0, schemas: &schemas)
            }
        ) { _, s in s }.nilIfEmpty,
        content: ContentObject(
					dictionaryElements: contentTypes.map { ($0, object) }
				)
    )
}

func responses(
    default defaultResponse: Codable?,
    types: [MediaType],
    headers: [Codable],
    errors errorResponses: [Int: Codable],
		descriptions: [Int: String],
    errorTypes: [MediaType],
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
												description: descriptions[$0.key] ?? Abort(HTTPResponseStatus(statusCode: $0.key)).reason,
                        contentTypes: errorTypes,
                        headers: errorHeaders,
                        schemas: &schemas
                    )
                )
            )
				} + descriptions.filter({ errorResponses[$0.key] == nil }).compactMap {
					(
						ResponsesObject.Key.code($0.key),
						.value(
							ResponseObject(description: $0.value)
						)
					)
				}
    ) { _, new in new }
    if let defaultResponse {
        responses[200] = try? .value(
            response(
                defaultResponse,
                description: "Success",
                contentTypes: types,
                headers: headers,
                schemas: &schemas
            )
        )
    }
    guard !responses.isEmpty else { return nil }
    return ResponsesObject(responses)
}

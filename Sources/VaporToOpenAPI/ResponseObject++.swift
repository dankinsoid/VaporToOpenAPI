import Foundation
import SwiftOpenAPI
import Vapor

func response(
	_ body: OpenAPIValue?,
	description: String,
	contentTypes: [MediaType],
	headers: OpenAPIValue?,
	schemas: inout [String: ReferenceOr<SchemaObject>],
	examples: inout [String: ReferenceOr<ExampleObject>]
) throws -> ResponseObject {
	let object = try body?.mediaTypeObject(schemas: &schemas, examples: &examples)
	return try ResponseObject(
		description: description,
		headers: headers?.headers(schemas: &schemas).nilIfEmpty,
		content: object.map { object in
			ContentObject(
				dictionaryElements: (contentTypes.nilIfEmpty ?? [.application(.json)]).map { ($0, object) }
			)
		}
	)
}

func responses(
	current: ResponsesObject?,
	responses: [ResponsesObject.Key: OpenAPIValue],
	descriptions: [ResponsesObject.Key: String],
	types: [ResponsesObject.Key: [MediaType]],
	headers: [ResponsesObject.Key: OpenAPIValue],
	schemas: inout [String: ReferenceOr<SchemaObject>],
	examples: inout [String: ReferenceOr<ExampleObject>]
) -> ResponsesObject? {
	var result: [ResponsesObject.Key: ResponsesObject.Value] = Dictionary(
		Set(responses.keys).union(descriptions.keys).compactMap { key in
			try? (
				key,
				.value(
					response(
						responses[key],
						description: descriptions[key] ?? description(for: key),
						contentTypes: types[key] ?? [.application(.json)],
						headers: headers[key],
						schemas: &schemas,
						examples: &examples
					)
				)
			)
		}
	) { _, new in new }
	result = result.merging(current?.value ?? [:]) { new, _ in
		new
	}
	guard !result.isEmpty else { return nil }
	return ResponsesObject(result)
}

private func description(for code: ResponsesObject.Key) -> String {
	switch code.intValue {
	case nil:
		return "Default response"
	case let .some(otherCode):
		return HTTPResponseStatus(statusCode: otherCode).reasonPhrase
	}
}

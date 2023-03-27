import Foundation
import SwiftOpenAPI

func request(
	body: Codable?,
	description: String?,
	required: Bool?,
	types: [MediaType],
	schemas: inout [String: ReferenceOr<SchemaObject>],
	examples: inout [String: ReferenceOr<ExampleObject>]
) -> ReferenceOr<RequestBodyObject>? {
	guard
		let body,
		let bodyObject = try? MediaTypeObject.encode(body, schemas: &schemas, examples: &examples)
	else {
		return nil
	}
	return .value(
		RequestBodyObject(
			description: description,
			content: ContentObject(
				dictionaryElements: types.map { ($0, bodyObject) }
			),
			required: required
		)
	)
}

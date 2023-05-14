import Foundation
import SwiftOpenAPI

func request(
	body: Any?,
	description: String?,
	required: Bool?,
	types: [MediaType],
	schemas: inout [String: ReferenceOr<SchemaObject>],
	examples: inout [String: ReferenceOr<ExampleObject>]
) -> ReferenceOr<RequestBodyObject>? {
	guard
		let body,
        let bodyObject = try? OpenAPIValue(body).mediaTypeObject(schemas: &schemas, examples: &examples)
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

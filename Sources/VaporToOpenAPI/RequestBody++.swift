import Foundation
import SwiftOpenAPI

func request(
	body: OpenAPIValue?,
	description: String?,
	required: Bool,
	types: [OpenAPI.ContentType],
	schemas: inout OpenAPI.ComponentDictionary<JSONSchema>,
	examples: inout OpenAPI.ComponentDictionary<OpenAPI.Example>
) -> Either<OpenAPI.Reference<OpenAPI.Request>, OpenAPI.Request>? {
	guard
		let bodyObject = try? body?.content(schemas: &schemas, examples: &examples)
	else {
		return nil
	}
	return .b(
        OpenAPI.Request(
			description: description,
            content: OpenAPI.Content.Map(
				(types.nilIfEmpty ?? [.json]).map { ($0, bodyObject) }
            ) { _, new in new },
			required: required
		)
	)
}

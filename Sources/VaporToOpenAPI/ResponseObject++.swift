import Foundation
import SwiftOpenAPI
import Vapor
import OpenAPIKit

func response(
	_ body: OpenAPIValue?,
	description: String,
	contentTypes: [OpenAPI.ContentType],
	headers: OpenAPIValue?,
	schemas: inout OpenAPI.ComponentDictionary<JSONSchema>,
	examples: inout OpenAPI.ComponentDictionary<OpenAPI.Example>
) throws -> OpenAPI.Response {
	let object = try body?.content(schemas: &schemas, examples: &examples)
    return try OpenAPI.Response(
		description: description,
		headers: headers?.headers(schemas: &schemas).nilIfEmpty,
		content: object.map { object in
            OpenAPI.Content.Map(
                (contentTypes.nilIfEmpty ?? [.json]).map { ($0, object) }
            ) { _, new in new }
        } ?? [:]
	)
}

func responses(
	current: OpenAPI.Response.Map?,
    responses: [OpenAPI.Response.StatusCode: OpenAPIValue],
	descriptions: [OpenAPI.Response.StatusCode: String],
	types: [OpenAPI.Response.StatusCode: [OpenAPI.ContentType]],
	headers: [OpenAPI.Response.StatusCode: OpenAPIValue],
	schemas: inout OpenAPI.ComponentDictionary<JSONSchema>,
	examples: inout OpenAPI.ComponentDictionary<OpenAPI.Example>
) -> OpenAPI.Response.Map? {
	var result: OpenAPI.Response.Map = OpenAPI.Response.Map(
		Set(responses.keys).union(descriptions.keys).compactMap { key in
			try? (
				key,
				.b(
					response(
						responses[key],
						description: descriptions[key] ?? description(for: key),
						contentTypes: types[key] ?? [.json],
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
	return result
}

private func description(for code: OpenAPI.Response.Map.Key) -> String {
    switch code.value {
    case .default:
        return "Default"
    case .range(let range):
        switch range {
        case .information:
            return "Information"
        case .success:
            return "Success"
        case .redirect:
            return "Redirect"
        case .clientError:
            return "Client error"
        case .serverError:
            return "Server error"
        }
    case .status(let code):
        return HTTPResponseStatus(statusCode: code).reasonPhrase
    }
}

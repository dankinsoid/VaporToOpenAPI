import Foundation
import SwiftOpenAPI

func request(
    body: WithExample.Type?,
    description: String?,
    required: Bool?,
    type: MediaType,
    schemas: inout [String: ReferenceOr<SchemaObject>]
) -> ReferenceOr<RequestBodyObject>? {
    body.flatMap {
        try? .value(
            RequestBodyObject(
                description: description,
                content: [
                    type: .encode($0.example, schemas: &schemas)
                ],
                required: required
            )
        )
    }
}

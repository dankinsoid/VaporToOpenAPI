//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Vapor
import Swiftgger
import VDCodable

extension Route {
	public var apiAction: APIAction {
		APIAction(
			method: method.openAPI,
			route: "/" + path.openAPIString,
			summary: summary,
			description: userInfo(for: DescriptionKey.self) ?? "",
			parameters: pathAPIParameters + queryAPIParameters + headerAPIParameters + cookieAPIParameters,
			request: openAPIRequestType.map {
				APIRequest(
            type: APIBodyType(
                type: $0,
                example: ($0 as? any WithExample.Type)?.example
            ),
            contentType: contentType(for: $0)
        )
			},
			responses: [successAPIResponse] + responses,
			authorization: responseType is Authenticatable
		)
	}
	
	public var successAPIResponse: APIResponse {
		APIResponse(
        code: "200",
        description: "Success response",
        type: (openAPIResponseType as? Decodable.Type).map {
            APIBodyType(
                type: $0,
                example: ($0 as? any WithExample.Type)?.example
            )
        } ?? .object(openAPIResponseType, asCollection: false),
        contentType: contentType(type: openAPIResponseType)
    )
	}
	
	public var pathAPIParameters: [APIParameter] {
		path.compactMap {
			if case .parameter(let name) = $0 {
				return APIParameter(name: name, parameterLocation: .path, description: nil, required: true, deprecated: false, allowEmptyValue: false)
			} else {
				return nil
			}
		}
	}
	
	public var queryAPIParameters: [APIParameter] {
		queryType.properties().map {
			APIParameter(
        name: $0.0,
        parameterLocation: .query,
        description: nil,
        required: !$0.1.isOptional,
        deprecated: false,
        allowEmptyValue: false,
        dataType: $0.1.0
      )
		}
	}
	
	public var headerAPIParameters: [APIParameter] {
      (headersType as [any WithExample.Type]).properties()
          .filter({ $0.0 != "cookie" })
          .map {
			APIParameter(
        name: $0.0,
        parameterLocation: .header,
        description: nil,
        required: !$0.1.isOptional,
        deprecated: false,
        allowEmptyValue: false,
        dataType: $0.1.0
      )
		}
	}
	
	public var cookieAPIParameters: [APIParameter] {
      let values = headersType.map { $0.example.cookie }
      let properties = values.compactMap {
          try? DictionaryEncoder().encode(AnyEncodable($0)) as? [String: Any]
      }
      return properties.joined().sorted(by: { $0.key < $1.key }).map {
			APIParameter(
        name: $0.key,
        parameterLocation: .cookie,
        description: nil,
        required: !isOptional($0.value),
        deprecated: false,
        allowEmptyValue: false,
        dataType: APIDataType(fromSwiftValue: $0.value) ?? .string
      )
		}
	}
	
	private func contentType(type: Any.Type) -> String? {
		(type as? OpenAPIContent.Type).map { "application/" + $0.defaultContentType.type }
	}
	
	private func contentType(for object: Any) -> String? {
		contentType(type: type(of: object))
	}
}

private struct AnyEncodable: Encodable {
	var encodable: Encodable
	
	init(_ encodable: Encodable) {
		self.encodable = encodable
	}
	
	func encode(to encoder: Encoder) throws {
		try encodable.encode(to: encoder)
	}
}

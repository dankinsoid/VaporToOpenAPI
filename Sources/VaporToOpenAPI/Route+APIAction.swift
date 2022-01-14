//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Vapor
import Swiftgger

extension Route {
	public var apiAction: APIAction {
		APIAction(
			method: method.openAPI,
			route: "/" + path.openAPIString,
			summary: summary,
			description: userInfo(for: DescriptionKey.self) ?? "",
			parameters: pathAPIParameters + queryAPIParameters + headerAPIParameters + cookieAPIParameters,
			request: openAPIRequestType.map {
				print($0, APIBodyType(type: $0, example: nil))
				return APIRequest(type: .init(type: $0, example: ($0 as? OpenAPIObject.Type)?.init()), contentType: contentType(for: $0))
			},
			responses: [successAPIResponse] + responses,
			authorization: responseType is Authenticatable
		)
	}
	
	public var successAPIResponse: APIResponse {
		return APIResponse(code: "200", description: "Success response", type: (responseType as? Decodable.Type).map { APIBodyType(type: $0, example: ($0 as? OpenAPIObject.Type)?.init()) } ?? .object(responseType, asCollection: false), contentType: contentType(type: responseType))
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
			APIParameter(name: $0.0, parameterLocation: .query, description: nil, required: !$0.1.isOptional, deprecated: false, allowEmptyValue: false, dataType: $0.1.0)
		}
	}
	
	public var headerAPIParameters: [APIParameter] {
		headersType.properties().filter({ $0.0 != "cookie" }).map {
			APIParameter(name: $0.0, parameterLocation: .header, description: nil, required: !$0.1.isOptional, deprecated: false, allowEmptyValue: false, dataType: $0.1.0)
		}
	}
	
	public var cookieAPIParameters: [APIParameter] {
		[]
	}
	
	private func contentType(type: Any.Type) -> String? {
	  nil//(type as? Content.Type)?.defaultContentType.type
	}
	
	private func contentType(for object: Any) -> String? {
		contentType(type: type(of: object))
	}
}

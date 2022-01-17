//
//  swagger.swift
//  
//
//  Created by Данил Войдилов on 26.12.2021.
//

import Vapor
import Swiftgger

extension Routes {
	public func openAPI(
		title: String,
		version: String,
		description: String,
		termsOfService: String? = nil,
		contact: APIContact? = nil,
		license: APILicense? = nil,
		authorizations: [APIAuthorizationType]? = nil,
		servers: [APIServer] = []
	) -> OpenAPIDocument {
		var openAPIBuilder = OpenAPIBuilder(
			title: title,
			version: version,
			description: description,
			termsOfService: termsOfService,
			contact: contact,
			license: license, 
			authorizations: authorizations
		)
		
		Dictionary(
			all.map {
				($0.path.first?.description ?? "", [$0])
			}
		) {
			$0 + $1
		}
		.sorted(by: { $0.key < $1.key })
		.forEach {
			openAPIBuilder = openAPIBuilder
				.addController(
					name: $0.key,
					description: $0.key,
					routes: $0.value
				)
		}
		
		openAPIBuilder = openAPIBuilder
			.add(
				all.flatMap {
					[$0.openAPIResponseType as? WithAnyExample.Type, $0.openAPIRequestType as? WithAnyExample.Type].compactMap({ $0 })
				}
					.filter({ $0 as? APIPrimitiveType == nil })
					.removeEqual(by: { String(reflecting: $0) })
					.map { APIObject(object: $0.anyExample) }
			)
		
		openAPIBuilder = servers.reduce(into: openAPIBuilder, { $0 = $0.add($1) })
		
		return openAPIBuilder.built()
	}
}

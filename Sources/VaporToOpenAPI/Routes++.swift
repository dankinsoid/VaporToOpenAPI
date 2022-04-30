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
		servers: [APIServer] = [],
		objects: [APIObject] = [],
		map: (Route) -> Route = { $0 }
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
		let routes = all.map(map)
		Dictionary(
			routes.map {
				($0.path.first?.name ?? "Any", [$0])
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
				routes.flatMap {
					[$0.openAPIResponseType as? AnyOpenAPIObjectConvertable.Type, $0.openAPIRequestType as? AnyOpenAPIObjectConvertable.Type].compactMap({ $0?.anyObjectAPIType })
				}
					.filter({ $0 as? APIPrimitiveType == nil })
					.removeEqual(by: { String(reflecting: $0) })
					.map { APIObject(object: $0.anyExample) } + objects
			)
		
		openAPIBuilder = servers.reduce(into: openAPIBuilder, { $0 = $0.add($1) })
		
		return openAPIBuilder.built()
	}
}

extension PathComponent {
	var name: String {
		switch self {
		case .constant(let string):
			return string
		case .parameter(let string):
			return string
		case .anything:
			return "Any"
		case .catchall:
			return "Catchhall"
		}
	}
}

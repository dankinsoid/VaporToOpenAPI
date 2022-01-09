//
//  swagger.swift
//  
//
//  Created by Данил Войдилов on 26.12.2021.
//

import Vapor
import Swiftgger
import Foundation

public protocol SwaggerObject {
	init()
}

func swagger(routes: Routes) {
	var openAPIBuilder = OpenAPIBuilder(
		title: "Tasker server API",
		version: "1.0.0",
		description: "This is a sample server for task server application.",
		termsOfService: "http://example.com/terms/",
		contact: APIContact(name: "John Doe", email: "john.doe@some-email.org", url: URL(string: "http://example-domain.com/@john")),
		license: APILicense(name: "MIT", url: URL(string: "http://mit.license")),
		authorizations: [.jwt(description: "You can get token from *sign-in* action from *Account* controller.")]
	)
		.add(
		APIController(
			name: "Users",
			description: "Controller where we can manage users",
			actions: routes.all.map { route in
				APIAction(
					method: route.method.swagger,
					route: "/" + route.path.string,
					summary: route.summary,
					description: route.userInfo(for: DescriptionKey.self) ?? "",
					parameters: [
//						APIParameter(name: <#T##String#>, parameterLocation: .query, description: nil, required: <#T##Bool#>, deprecated: <#T##Bool#>, allowEmptyValue: <#T##Bool#>, dataType: <#T##APIDataType#>)
					],
					request: route.swaggerRequestType.map { APIRequest(object: $0, description: nil, contentType: nil) },
					responses: [
						APIResponse(code: "200", description: "Success response", object: route.responseType, contentType: nil)
					] + (route.responses),
					authorization: route.responseType is Authenticatable
				)
			}
		)
	)
	
	openAPIBuilder = openAPIBuilder
		.add([APIObject(object: <#T##Any#>)])
}

public protocol RouteInfoKey {
	associatedtype Value = String
	static var name: String { get }
}

@dynamicMemberLookup
public struct RouteUserInfoValues {
	private let key = "user_infos"
	private var infos: [PartialKeyPath<Route>: Any] = [:]
	
	public subscript<T>(dynamicMember keyPath: KeyPath<Route, T>) -> T? {
		get { infos[keyPath] as? T }
		set { infos[keyPath] = newValue }
	}
	
	public subscript<T>(dynamicMember keyPath: KeyPath<Route, T?>) -> T? {
		get { (infos[keyPath] as? T?) ?? nil }
		set { infos[keyPath] = newValue }
	}
}

extension Route {
	public var summary: String {
		values.summary ?? ""
	}
	public var responses: [APIResponse] {
		values.responses ?? []
	}
}

public enum DescriptionKey: RouteInfoKey {
	public static let name = "description"
}

public enum UserInfoKey: RouteInfoKey {
	public typealias Value = RouteUserInfoValues
	public static let name = "user_info_values"
}

public enum RequestTypeKey: RouteInfoKey {
	public typealias Value = Any.Type
	public static let name = "swagger_request_type"
}

extension Route {
	
	public var values: RouteUserInfoValues {
		get {
			userInfo(for: UserInfoKey.self) ?? RouteUserInfoValues()
		}
		set {
			userInfo(key: UserInfoKey.self, newValue)
		}
	}
	
	public var swaggerRequestType: Any.Type? {
		userInfo(for: RequestTypeKey.self) ?? (requestType == Request.self ? nil : requestType)
	}
	
	@discardableResult
	public func set<T>(_ keyPath: KeyPath<Route, T>, to value: T?) -> Route {
		values[dynamicMember: keyPath] = value
		return self
	}
	
	@discardableResult
	public func set<T>(_ keyPath: KeyPath<Route, T?>, to value: T?) -> Route {
		values[dynamicMember: keyPath] = value
		return self
	}
	
	@discardableResult
	public func userInfo<Key: RouteInfoKey>(key: Key.Type, _ value: Key.Value) -> Route {
		userInfo[Key.name] = value
		return self
	}
	
	public func userInfo<Key: RouteInfoKey>(for key: Key.Type) -> Key.Value? {
		userInfo[Key.name] as? Key.Value
	}
}

extension HTTPMethod {
	public var swagger: APIHttpMethod {
		switch self {
		case .GET:
			return .get
		case .PUT:
			return .put
		case .ACL:
			return .post
		case .HEAD:
			return .head
		case .POST:
			return .post
		case .CONNECT:
			return .connect
		case .PATCH:
			return .patch
		case .OPTIONS:
			return .options
		case .TRACE:
			return .trace
		case .DELETE:
			return .delete
		case .COPY, .LOCK, .MOVE, .BIND, .LINK, .MKCOL, .MERGE, .PURGE, .NOTIFY, .SEARCH, .UNLOCK, .REBIND, .UNBIND, .REPORT, .UNLINK, .MSEARCH, .PROPFIND, .CHECKOUT, .PROPPATCH, .SUBSCRIBE, .MKCALENDAR, .MKACTIVITY, .UNSUBSCRIBE, .SOURCE, .RAW:
			return .post
		}
	}
}

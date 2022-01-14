//
//  File.swift
//  
//
//  Created by Данил Войдилов on 10.01.2022.
//

import Vapor
import Swiftgger

extension RoutesBuilder {
	
	@discardableResult
	public func on<Response: ResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: PathComponent...,
		types: RequestTypes<Content, Headers, Query>,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) throws -> Response
	) -> Route {
		on(method, path, types: types, use: closure)
	}
	
	@discardableResult
	public func on<Response: ResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: [PathComponent],
		types: RequestTypes<Content, Headers, Query>,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) throws -> Response
	) -> Route {
		on(method, path, content: { try $0.decode(Content.self) }, query: { try $0.decode(Query.self) }, headers: { try $0.decode(Headers.self) }, use: closure)
	}
	
	@discardableResult
	public func on<Response: ResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: PathComponent...,
		content: @escaping (ContentContainer) throws -> Content,
		query: @escaping (URLQueryContainer) throws -> Query,
		headers: @escaping (HTTPHeaders) throws -> Headers,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) throws -> Response
	) -> Route {
		on(method, path, content: content, query: query, headers: headers, use: closure)
	}
	
	@discardableResult
	public func on<Response: ResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: [PathComponent],
		content: @escaping (ContentContainer) throws -> Content,
		query: @escaping (URLQueryContainer) throws -> Query,
		headers: @escaping (HTTPHeaders) throws -> Headers,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) throws -> Response
	) -> Route {
		on(method, path, body: body) {
			try closure(TypedRequest(erased: $0, query: query, content: content, headers: headers))
		}
		.set(\.contentType, to: Content.self)
		.set(\.queryType, to: Query.self)
		.set(\.headersType, to: Headers.self)
	}
}

#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension RoutesBuilder {
	
	@discardableResult
	public func on<Response: AsyncResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: [PathComponent],
		types: RequestTypes<Content, Headers, Query>,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) async throws -> Response
	) -> Route {
		on(method, path, content: { try $0.decode(Content.self) }, query: { try $0.decode(Query.self) }, headers: { try $0.decode(Headers.self) }, use: closure)
	}
	
	@discardableResult
	public func on<Response: AsyncResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: PathComponent...,
		types: RequestTypes<Content, Headers, Query>,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) async throws -> Response
	) -> Route {
		on(method, path, content: { try $0.decode(Content.self) }, query: { try $0.decode(Query.self) }, headers: { try $0.decode(Headers.self) }, use: closure)
	}
	
	@discardableResult
	public func on<Response: AsyncResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: PathComponent...,
		content: @escaping (ContentContainer) throws -> Content,
		query: @escaping (URLQueryContainer) throws -> Query,
		headers: @escaping (HTTPHeaders) throws -> Headers,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) async throws -> Response
	) -> Route {
		on(method, path, content: content, query: query, headers: headers, use: closure)
	}
	
	@discardableResult
	public func on<Response: AsyncResponseEncodable, Content: Decodable & OpenAPIObject, Headers: HeadersType & Decodable & OpenAPIObject, Query: Decodable & OpenAPIObject>(
		_ method: HTTPMethod,
		_ path: [PathComponent],
		content: @escaping (ContentContainer) throws -> Content,
		query: @escaping (URLQueryContainer) throws -> Query,
		headers: @escaping (HTTPHeaders) throws -> Headers,
		body: HTTPBodyStreamStrategy = .collect,
		use closure: @escaping (TypedRequest<Content, Headers, Query>) async throws -> Response
	) -> Route {
		on(method, path, body: body) {
			try await closure(TypedRequest(erased: $0, query: query, content: content, headers: headers))
		}
		.set(\.contentType, to: Content.self)
		.set(\.queryType, to: Query.self)
		.set(\.headersType, to: Headers.self)
	}
}
#endif

//
//  File.swift
//  
//
//  Created by Данил Войдилов on 10.01.2022.
//

import Vapor
import NIO

public struct TypedRequest<Content: Decodable, Headers: HeadersType & Decodable, Query: Decodable> {
	public let erased: Request
	
	public var application: Application { erased.application }
	
	/// The HTTP method for this request.
	///
	///     httpReq.method = .GET
	///
	public var method: HTTPMethod {
		get { erased.method }
		nonmutating set { erased.method = newValue }
	}
	
	/// The URL used on this request.
	public var url: URI {
		get { erased.url }
		nonmutating set { erased.url = newValue }
	}
	
	/// The version for this HTTP request.
	public var version: HTTPVersion {
		get { erased.version }
		nonmutating set { erased.version = newValue }
	}
	
	/// The header fields for this HTTP request.
	/// The `"Content-Length"` and `"Transfer-Encoding"` headers will be set automatically
	/// when the `body` property is mutated.
	private let _headers: (HTTPHeaders) throws -> Headers
	private let _query: (URLQueryContainer) throws -> Query
	private let _content: (ContentContainer) throws -> Content
	
	/// The header fields for this HTTP request.
	/// The `"Content-Length"` and `"Transfer-Encoding"` headers will be set automatically
	/// when the `body` property is mutated.
	public func headers() throws -> Headers {
		try _headers(erased.headers)
	}
	
	public func query() throws -> Query {
		try _query(erased.query)
	}
	
	public func content() throws -> Content {
		try _content(erased.content)
	}
	
	/// Get and set `HTTPCookies` for this `HTTPRequest`
	/// This accesses the `"Cookie"` header.
	public func cookie() throws -> Headers.Cookies { try headers().cookie }
	
	// MARK: Metadata
	
	/// Route object we found for this request.
	/// This holds metadata that can be used for (for example) Metrics.
	///
	///     req.route?.description // "GET /hello/:name"
	///
	public var route: Route? {
		get { erased.route }
		nonmutating set { erased.route = newValue }
	}
	
	/// This Logger from Apple's `swift-log` Package is preferred when logging in the context of handing this Request.
	/// Vapor already provides metadata to this logger so that multiple logged messages can be traced back to the same request.
	public var logger: Logger {
		get { erased.logger }
		nonmutating set { erased.logger = newValue }
	}
	
	public var body: Request.Body { erased.body }
	
	/// See `CustomStringConvertible`
	public var description: String { erased.description }
	
	/// The address from which this HTTP request was received by SwiftNIO.
	/// This address may not represent the original address of the peer, especially if Vapor receives its requests through a reverse-proxy such as nginx.
	public var remoteAddress: SocketAddress? { erased.remoteAddress }
	
	/// The `EventLoop` which is handling this `Request`. The route handler and any relevant middleware are invoked in this event loop.
	///
	/// - Warning: A futures-based route handler **MUST** return an `EventLoopFuture` bound to this event loop.
	///  If this is difficult or awkward to guarantee, use `EventLoopFuture.hop(to:)` to jump to this event loop.
	public var eventLoop: EventLoop { erased.eventLoop }
	
	/// A container containing the route parameters that were captured when receiving this request.
	/// Use this container to grab any non-static parameters from the URL, such as model IDs in a REST API.
	public var parameters: Parameters {
		get { erased.parameters }
		nonmutating set { erased.parameters = newValue }
	}
	
	/// This container is used as arbitrary request-local storage during the request-response lifecycle.Z
	public var storage: Storage {
		get { erased.storage }
		nonmutating set { erased.storage = newValue }
	}
	
	public init(
		erased: Request,
		query: @escaping (URLQueryContainer) throws -> Query = { try $0.decode(Query.self) },
		content: @escaping (ContentContainer) throws -> Content = { try $0.decode(Content.self) },
		headers: @escaping (HTTPHeaders) throws -> Headers = { try $0.decode(Headers.self) }
	) {
		self.erased = erased
		self._query = query
		self._content = content
		self._headers = headers
	}
	
	/// Creates a redirect `Response`.
	///
	///     router.get("redirect") { req in
	///         return req.redirect(to: "https://vapor.codes")
	///     }
	///
	/// Set type to '.permanently' to allow caching to automatically redirect from browsers.
	/// Defaulting to non-permanent to prevent unexpected caching.
	public func redirect(to location: String, type: RedirectType = .normal) -> Response {
		erased.redirect(to: location, type: type)
	}
}

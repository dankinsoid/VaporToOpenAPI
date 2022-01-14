//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Vapor
import Swiftgger

extension HTTPMethod {
	public var openAPI: APIHttpMethod {
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

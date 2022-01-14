//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.01.2022.
//

import NIOHTTP1

public protocol HTTPHeadersDecoderType {
	func decode<D>(_ decodable: D.Type, from headers: HTTPHeaders) throws -> D where D: HeadersType & Decodable
}

public protocol HTTPHeadersEncoderType {
	func encode<E>(_ encodable: E, to headers: inout HTTPHeaders) throws where E: HeadersType & Encodable
}

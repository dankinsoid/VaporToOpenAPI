//
//  File.swift
//  
//
//  Created by Данил Войдилов on 15.01.2022.
//

//import Foundation
//import NIOHTTP1
//import SimpleCoders
//
//public struct HTTPHeadersEncoder: HTTPHeadersEncoderType {
//	public func encode<E: Encodable & HeadersType>(_ encodable: E, to headers: inout HTTPHeaders) throws {
//		try encodable.encode(to: VDEncoder(boxer: SingleContainer()))
//	}
//}
//
//fileprivate struct SingleContainer: EncodingBoxer {
//	
//	enum Output {
//		case value(String), headers(HTTPHeaders)
//	}
//	
//	var codingPath: [CodingKey] = []
//	
//	init(path: [CodingKey], other boxer: SingleContainer) {
//		
//	}
//	
//	func encodeNil() throws -> Output {
//		
//	}
//	
//	func encode(_ dictionary: [String: Output]) throws -> Output {
//		
//	}
//	
//	func encode(_ array: [Output]) throws -> Output {
//		
//	}
//	
//	func encode(_ value: Bool) throws -> Output {
//		
//	}
//}

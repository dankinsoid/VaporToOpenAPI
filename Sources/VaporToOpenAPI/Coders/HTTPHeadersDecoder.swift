//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.01.2022.
//

import Foundation
import NIOHTTP1
import SimpleCoders
import VDCodable

public struct HTTPHeadersDecoder: HTTPHeadersDecoderType {
	public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
	
	public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) {
		self.dateDecodingStrategy = dateDecodingStrategy
	}
	
	public func decode<D>(_ decodable: D.Type, from headers: HTTPHeaders) throws -> D where D: Decodable & HeadersType {
		let unboxer = SingleContainer(input: .headers(headers), dateDecodingStrategy: dateDecodingStrategy)
		return try D.init(from: VDDecoder(unboxer: unboxer))
	}
}

fileprivate struct SingleContainer: DecodingUnboxer {
	enum Input {
		case value(String), headers(HTTPHeaders)
	}
	let input: Input
	let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
	let codingPath: [CodingKey]
	
	init(input: Input, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
		self.input = input
		self.dateDecodingStrategy = dateDecodingStrategy
		codingPath = []
	}
	
	init(input: Input, path: [CodingKey], other unboxer: SingleContainer) {
		self.input = input
		codingPath = path
		dateDecodingStrategy = unboxer.dateDecodingStrategy
	}
	
	private func decodeAny<T>(decode: (String) -> T?) throws -> T {
		guard case .value(let string) = input else {
			throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode single value"))
		}
		guard let result = decode(string) else {
			throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(T.self), but found \"\(string)\""))
		}
		return result
	}
	
	func decodeNil() -> Bool {
		guard case .value(let string) = input else { return false }
		return string.lowercased() == "null"
	}
	
	func decodeArray() throws -> [Input] {
		throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode nested array in HTTPHeaders", underlyingError: nil))
	}
	
	func decodeDictionary() throws -> [String: Input] {
		switch input {
		case .value(let string):
			return try dictionary(
				httpHeaders: string.components(separatedBy: "; ").map { pair in
					let comp = pair.components(separatedBy: "=")
					guard comp.count > 1 else {
						throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode nested object in HTTPHeaders", underlyingError: nil))
					}
					return (comp[0], comp.dropFirst().joined(separator: "="))
				}
			)
		case .headers(let httpHeaders):
			return dictionary(httpHeaders: httpHeaders)
		}
	}
	
	private func dictionary<C: Collection>(httpHeaders: C) -> [String: Input] where C.Element == (name: String, value: String) {
		var result: [String: Input] = [:]
		for (key, header) in httpHeaders {
			let key = KeyDecodingStrategy.keyFromSnakeCase(key, separators: CharacterSet(charactersIn: "-"))
			switch result[key] {
			case .value(let current):
				result[key] = .headers(HTTPHeaders([(key, current), (key, header)]))
			case .headers(var current):
				current.add(name: key, value: header)
				result[key] = .headers(current)
			case .none:
				result[key] = .value(header)
			}
		}
		return result
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		try decodeAny {
			switch $0.lowercased() {
			case "true", "yes", "1": return true
			case "false", "no", "0": return false
			default: return nil
			}
		}
	}
	
	func decode(_ type: String.Type) throws -> String { return try decodeAny { $0 } }
	func decode(_ type: Double.Type) throws -> Double { return try decodeAny { Double($0) } }
	func decode(_ type: Int.Type) throws -> Int { return try decodeAny { Int($0) } }
	func decode(_ type: UInt.Type) throws -> UInt { return try decodeAny { UInt($0) } }
	
	func decode<T: Decodable>(_ type: T.Type) throws -> T {
		if let result = input as? T {
			return result
		}
		let decoder = VDDecoder(unboxer: self)
		if type == Date.self || type as? NSDate.Type != nil {
			let result = try decodeDate(from: decoder)
			return try cast(result, as: type)
		}
		return try T(from: decoder)
	}
	
	@inline(__always)
	private func decodeDate(from decoder: Decoder) throws -> Date {
		switch dateDecodingStrategy {
		case .deferredToDate:
			return try Date(from: decoder)
		case .secondsSince1970:
			let seconds = try Double(from: decoder)
			return Date(timeIntervalSince1970: seconds)
		case .millisecondsSince1970:
			let milliseconds = try Double(from: decoder)
			return Date(timeIntervalSince1970: milliseconds / 1000)
		case .iso8601:
			let string = try String(from: decoder)
			if let result = _iso8601Formatter.date(from: string) {
				return result
			} else {
				throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
			}
		case .formatted(let formatter):
			let string = try String(from: decoder)
			if let result = formatter.date(from: string) {
				return result
			} else {
				throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string does not match format expected by formatter."))
			}
		case .custom(let transform):
			return try transform(decoder)
		@unknown default:
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown case."))
		}
	}
	
	private func cast<A, T>(_ value: A, as type: T.Type) throws -> T {
		if let result = value as? T {
			return result
		} else {
			throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(type) but found \(String(describing: A.self)) instead."))
		}
	}
}

fileprivate let _dateFormatter = DateFormatter()
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
internal let _iso8601Formatter: ISO8601DateFormatter = {
	let formatter = ISO8601DateFormatter()
	formatter.formatOptions = .withInternetDateTime
	return formatter
}()

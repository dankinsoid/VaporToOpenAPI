//
//  File 2.swift
//  
//
//  Created by Данил Войдилов on 11.01.2022.
//

import Foundation

public struct PlainCodingKey: CodingKey, ExpressibleByStringInterpolation, CustomStringConvertible {
	public var stringValue: String
	public var intValue: Int?
	
	public var description: String {
		if let i = intValue {
			return "\(i)"
		} else {
			return stringValue
		}
	}
	
	public init?(intValue: Int) {
		self.intValue = intValue
		self.stringValue = "\(intValue)"
	}
	
	public init?(stringValue: String) {
		self.stringValue = stringValue
	}
	
	public init(stringInterpolation: String.StringInterpolation) {
		self = PlainCodingKey(String(stringInterpolation: stringInterpolation))
	}
	
	public init(stringLiteral value: String.StringLiteralType) {
		self = PlainCodingKey(String(stringLiteral: value))
	}
	
	public init(_ string: String) {
		stringValue = string
	}
	
	public init(_ int: Int) {
		stringValue = "\(int)"
		intValue = int
	}
	
	public init(_ key: CodingKey) {
		stringValue = key.stringValue
		intValue = key.intValue
	}
}

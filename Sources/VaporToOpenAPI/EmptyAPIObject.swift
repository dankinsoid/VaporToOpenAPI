//
//  File.swift
//  
//
//  Created by Данил Войдилов on 10.01.2022.
//

import Vapor
import Swiftgger

public struct EmptyAPIObject: OpenAPIObject, Codable {
	public init() {}
	public init(from decoder: Decoder) throws {}
}

extension EmptyAPIObject: HeadersType {}

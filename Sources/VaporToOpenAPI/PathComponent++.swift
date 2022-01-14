//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Vapor

extension PathComponent {
	
	public var openAPIDescription: String {
		switch self {
		case .anything:
			return "*"
		case .catchall:
			return "**"
		case .parameter(let name):
			return "{\(name)}"
		case .constant(let constant):
			return constant
		}
	}
}

extension Sequence where Element == PathComponent {
	/// Converts an array of `PathComponent` into a OpenAPI path string.
	///
	///     galaxies/{galaxyID}/planets
	///
	public var openAPIString: String {
		return self.map(\.openAPIDescription).joined(separator: "/")
	}
}

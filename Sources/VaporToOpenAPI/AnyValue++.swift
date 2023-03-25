import Foundation
import SwiftOpenAPI

extension AnyValue {

	func firstDifferentKey(with other: AnyValue) -> String {
		switch (self, other) {
		case let (.object(lhs), .object(rhs)):
			for key in Set(lhs.keys).union(rhs.keys) {
				let (l, r) = (lhs[key], rhs[key])
				guard l != r else { continue }
				if let l, let r {
					return [key, l.firstDifferentKey(with: r)].filter { !$0.isEmpty }.joined(separator: ".")
				} else {
					return key
				}
			}
			return ""

		case let (.array(lhs), .array(rhs)):
			for i in 0 ..< min(lhs.count, rhs.count) {
				let (l, r) = (lhs[i], rhs[i])
				guard l != r else { continue }
				return ["\(i)", l.firstDifferentKey(with: r)].filter { !$0.isEmpty }.joined(separator: ".")
			}
			if lhs.count != rhs.count {
				let i = min(lhs.count, rhs.count)
				return "\(i)"
			}
			return ""
		default:
			return ""
		}
	}

	private var flatten: [String: AnyValue] {
		switch self {
		case .string, .bool, .int, .double:
			return [:]

		case let .object(dictionary):
			return Dictionary(
				dictionary.flatMap { key, value in
					let nested = value.flatten
					if nested.isEmpty {
						return [(key, value)]
					} else {
						return nested.map {
							("\(key).\($0.key)", $0.value)
						}
					}
				}
			) { _, n in n }

		case let .array(array):
			return Dictionary(
				array.indices.flatMap { i in
					let nested = array[i].flatten
					let key = "\(i)"
					if nested.isEmpty {
						return [(key, array[i])]
					} else {
						return nested.map {
							("\(key).\($0.key)", $0.value)
						}
					}
				}
			) { _, n in n }
		}
	}

	func path(upTo key: String) -> [String] {
		switch self {
		case .string, .bool, .int, .double:
			return []

		case let .object(dictionary):
			if dictionary[key] != nil {
				return [key]
			}
			for (k, value) in dictionary {
				let path = value.path(upTo: key)
				if !path.isEmpty {
					return [k] + path
				}
			}
			return []

		case let .array(array):
			if let int = Int(key), array.indices.contains(int) {
				return [key]
			}
			for i in array.indices {
				let path = array[i].path(upTo: key)
				if !path.isEmpty {
					return ["\(i)"] + path
				}
			}
			return []
		}
	}

	func path(upTo value: AnyValue) -> [String] {
		switch self {
		case .string, .bool, .int, .double:
			return []

		case let .object(dictionary):
			if let key = dictionary.first(where: { $0.value == value })?.key {
				return [key]
			}
			for (key, v) in dictionary {
				let path = v.path(upTo: value)
				if !path.isEmpty {
					return [key] + path
				}
			}
			return []

		case let .array(array):
			if let i = array.firstIndex(where: { $0 == value }) {
				return ["\(i)"]
			}
			for i in array.indices {
				let path = array[i].path(upTo: value)
				if !path.isEmpty {
					return ["\(i)"] + path
				}
			}
			return []
		}
	}
}

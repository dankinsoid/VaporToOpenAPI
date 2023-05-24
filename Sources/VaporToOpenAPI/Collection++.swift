import Foundation

extension Collection {

	var nilIfEmpty: Self? {
		isEmpty ? nil : self
	}

	func removeEquals(_ compare: (Element) -> some Equatable) -> [Element] {
		var result: [Element] = []
		for element in self where !result.contains(where: { compare($0) == compare(element) }) {
			result.append(element)
		}
		return result
	}
}

extension Collection where Element: Equatable {

	var removeEquals: [Element] {
		removeEquals { $0 }
	}
}

extension Dictionary {

	func mapKeys<T>(_ map: (Key) -> T) -> [T: Value] {
		[T: Value](self.map { (map($0.key), $0.value) }) { _, new in
			new
		}
	}

	func mapKeys<T, V>(_ map: (Key) -> T, values: (Value) -> V) -> [T: V] {
		[T: V](self.map { (map($0.key), values($0.value)) }) { _, new in
			new
		}
	}
}

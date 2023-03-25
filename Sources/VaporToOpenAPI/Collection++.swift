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

import Foundation

extension String {

	var upFirst: String {
		guard !isEmpty else { return "" }
		return self[startIndex].uppercased() + dropFirst()
	}
}

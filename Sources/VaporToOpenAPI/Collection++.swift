import Foundation

extension Collection {
    
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Collection where Element: Equatable {
    
    var removeEquals: [Element] {
        var result: [Element] = []
        for element in self where !result.contains(element) {
            result.append(element)
        }
        return result
    }
}

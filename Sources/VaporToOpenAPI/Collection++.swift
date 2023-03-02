import Foundation

extension Collection {
    
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

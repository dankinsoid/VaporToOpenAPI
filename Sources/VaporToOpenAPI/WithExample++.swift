import Foundation

public extension WithExample {
    
    static func codingKey<Value: DetectableType>(for keyPath: WritableKeyPath<Self, Value>) -> String {
        if let result = cache[keyPath] { return result }
        var example = Self.example
        let value1 = (try? AnyValue.encode(example)) ?? [:]
        example[keyPath: keyPath] = Value.another(for: example[keyPath: keyPath])
        let value2 = (try? AnyValue.encode(example)) ?? [:]
        let key = value1.firstDifferentKey(with: value2)
        cache[keyPath] = key
        return key
    }
}

private var cache: [AnyKeyPath: String] = [:]

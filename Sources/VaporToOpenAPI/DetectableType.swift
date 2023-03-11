import Foundation

public protocol DetectableType: Equatable {
    
    static func another(for value: Self) -> Self
}

extension Bool: DetectableType {
    
    public static func another(for value: Self) -> Self { !value }
}

extension String: DetectableType {
    
    public static func another(for value: Self) -> Self { value.isEmpty ? " " : "" }
}

extension Double: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension Float: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension Decimal: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension Int: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension Int8: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension Int16: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}


extension Int32: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension Int64: DetectableType {
    
    public static func another(for value: Self) -> Self { -value }
}

extension UInt: DetectableType {
    
    public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt8: DetectableType {
    
    public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt16: DetectableType {
    
    public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt32: DetectableType {
    
    public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt64: DetectableType {
    
    public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UUID: DetectableType {
    
    public static func another(for value: Self) -> Self { UUID() }
}

extension Optional: DetectableType where Wrapped: WithExample & Equatable {
    
    public static func another(for value: Self) -> Self {
        value == nil ? .example : nil
    }
}

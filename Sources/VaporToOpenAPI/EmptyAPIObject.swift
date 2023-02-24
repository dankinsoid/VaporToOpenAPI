import Vapor
import Swiftgger

public struct EmptyAPIObject: OpenAPIComponent, Codable {
    
	public static var example: EmptyAPIObject { EmptyAPIObject() }
    
	public init() {}
    
	public init(from decoder: Decoder) throws {}
}

extension EmptyAPIObject: HeadersType {}

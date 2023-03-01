import Foundation

public protocol WithExample: Codable {
    
	static var example: Self { get }
}

extension Array: WithExample where Element: WithExample {
    
    public static var example: Array { [.example] }
}

extension Set: WithExample where Element: WithExample {
    
    public static var example: Set { [.example] }
}

extension ContiguousArray: WithExample where Element: WithExample {
    
    public static var example: ContiguousArray { [.example] }
}

extension String: WithExample {
    
	public static var example: String { "some string" }
}

extension Data: WithExample {
    
	public static var example: Data { Data() }
}

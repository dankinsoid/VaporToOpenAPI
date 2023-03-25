import Foundation

public enum OrderStatus: String, Codable, CaseIterable {
	
	case placed, approved, delivered
}

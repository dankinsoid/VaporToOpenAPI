import Foundation
import Vapor

public struct Order: Codable, Equatable, Content {

	public var id: Int
	public var petId: Int
	public var quantity: Int32?
	public var shipDate: Date?
	public var status: OrderStatus
	public var complete: Bool?
	
	public static let example = Order(
		id: 10,
		petId: 198772,
		quantity: 7,
		shipDate: Date(timeIntervalSince1970: 1_000_000),
		status: .approved,
		complete: false
	)
}

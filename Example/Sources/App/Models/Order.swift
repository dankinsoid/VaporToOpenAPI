import Foundation
import SwiftOpenAPI
import Vapor
import VaporToOpenAPI

@OpenAPIDescriptable
/// Order
public struct Order: Codable, Equatable, Content, WithExample {

	/// Unique identifier for the order
	public var id: Int
	/// Pet sold to
	public var petId: Int
	/// Quantity sold
	public var quantity: Int32?
	/// Estimated ship date
	public var shipDate: Date?
	/// Order Status
	public var status: OrderStatus
	/// Is the order complete?
	public var complete: Bool?

	public static let example = Order(
		id: 10,
		petId: 198_772,
		quantity: 7,
		shipDate: Date(timeIntervalSince1970: 1_000_000),
		status: .approved,
		complete: false
	)
}

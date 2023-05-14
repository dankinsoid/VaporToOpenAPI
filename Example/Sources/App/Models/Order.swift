import Foundation
import Vapor
import VaporToOpenAPI
import SwiftOpenAPI

public struct Order: Codable, Equatable, Content, WithExample, OpenAPIDescriptable {

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

		public static var openAPIDescription: OpenAPIDescriptionType? {
			OpenAPIDescription<CodingKeys>("Order")
				.add(for: .id, "Unique identifier for the order")
				.add(for: .petId, "Pet sold to")
				.add(for: .quantity, "Quantity sold")
				.add(for: .shipDate, "Estimated ship date")
				.add(for: .status, "Order Status")
				.add(for: .complete, "Is the order complete?")
	}
}

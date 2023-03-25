import Foundation

public enum Headers {

	public struct XRateLimit: Codable {

		public var xRateLimit: Int32

		public enum CodingKeys: String, CodingKey {

			case xRateLimit = "X-Rate-Limit"
		}

		public static let example = XRateLimit(xRateLimit: 10)
	}

	public struct XExpiresAfter: Codable {

		public var xExpiresAfter: Date

		public enum CodingKeys: String, CodingKey {

			case xExpiresAfter = "X-Expires-After"
		}

		public static let example = XExpiresAfter(
			xExpiresAfter: Date(timeIntervalSince1970: 1_000_000)
		)
	}
}

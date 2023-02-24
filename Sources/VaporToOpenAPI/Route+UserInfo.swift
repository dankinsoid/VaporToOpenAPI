import Vapor

public protocol RouteInfoKey {
	associatedtype Value = String
	static var name: String { get }
}

public enum DescriptionKey: RouteInfoKey {
	public static let name = "description"
}

public enum UserInfoKey: RouteInfoKey {
	public typealias Value = RouteUserInfoValues
	public static let name = "user_info_values"
}

@dynamicMemberLookup
public struct RouteUserInfoValues {
	private let key = "user_infos"
	private var infos: [PartialKeyPath<Route>: Any] = [:]
	
	public subscript<T>(dynamicMember keyPath: KeyPath<Route, T>) -> T? {
		get { infos[keyPath] as? T }
		set { infos[keyPath] = newValue }
	}
	
	public subscript<T>(dynamicMember keyPath: KeyPath<Route, T?>) -> T? {
		get { (infos[keyPath] as? T?) ?? nil }
		set { infos[keyPath] = newValue }
	}
}

extension Route {
	
	public var values: RouteUserInfoValues {
		get {
			userInfo(for: UserInfoKey.self) ?? RouteUserInfoValues()
		}
		set {
			userInfo(key: UserInfoKey.self, newValue)
		}
	}
	
	@discardableResult
	public func set<T>(_ keyPath: KeyPath<Route, T>, to value: T?) -> Route {
		values[dynamicMember: keyPath] = value
		return self
	}
	
	@discardableResult
	public func set<T>(_ keyPath: KeyPath<Route, T?>, to value: T?) -> Route {
		values[dynamicMember: keyPath] = value
		return self
	}
	
	@discardableResult
	public func userInfo<Key: RouteInfoKey>(key: Key.Type, _ value: Key.Value) -> Route {
		userInfo[Key.name] = value
		return self
	}
	
	public func userInfo<Key: RouteInfoKey>(for key: Key.Type) -> Key.Value? {
		userInfo[Key.name] as? Key.Value
	}
}

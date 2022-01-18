//
//  File.swift
//  
//
//  Created by Данил Войдилов on 15.01.2022.
//

import NIO

protocol EventLoopType {
	static var valueType: Any.Type { get }
}

extension EventLoopFuture: EventLoopType {
	static var valueType: Any.Type { Value.self }
}

extension EventLoopPromise: EventLoopType {
	static var valueType: Any.Type { Value.self }
}

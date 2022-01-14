//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Foundation

extension Collection {
	
	public func removeEqual<H: Equatable>(by get: (Element) -> H) -> [Element] {
		reduce(into: []) { result, element in
			if !result.contains(where: { get($0) == get(element) }) {
				result.append(element)
			}
		}
	}
}
